# frozen_string_literal: true

class UffizziCore::Cli::ComposeFileService
  class << self
    def create(params, kind)
      compose_file_form = create_compose_form(params, kind)

      process_compose_file(compose_file_form, params)
    end

    def update(compose_file, params)
      compose_file_form = create_update_compose_form(compose_file, params)

      process_compose_file(compose_file_form, params)
    end

    def parse(compose_content, compose_payload = {})
      compose_data = load_compose_data(compose_content)
      check_config_options_format(compose_data)
      configs_data = UffizziCore::ComposeFile::ConfigsOptionsService.parse(compose_data['configs'])
      secrets_data = UffizziCore::ComposeFile::SecretsOptionsService.parse(compose_data['secrets'])
      containers_data = UffizziCore::ComposeFile::ServicesOptionsService.parse(compose_data['services'], configs_data, secrets_data,
                                                                               compose_payload)

      continuous_preview_option = UffizziCore::ComposeFile::ConfigOptionService.continuous_preview_option(compose_data)
      continuous_preview_data = UffizziCore::ComposeFile::ContinuousPreviewOptionsService.parse(continuous_preview_option)

      ingress_option = UffizziCore::ComposeFile::ConfigOptionService.ingress_option(compose_data)
      ingress_data = UffizziCore::ComposeFile::IngressOptionsService.parse(ingress_option, compose_data['services'])

      {
        containers: containers_data,
        ingress: ingress_data,
        continuous_preview: continuous_preview_data,
      }
    end

    def load_repositories(compose_data, credential)
      containers = github_containers(compose_data)
      return [] if containers.empty?

      search_query = 'fork:true '
      search_query += containers.reduce('') do |query, container|
        query += "repo:#{credential.username}/#{container[:build][:repository_name]} "
        query
      end

      UffizziCore::Github::CredentialService.search_repositories(credential, search_query)
    end

    def check_github_branches(compose_data, repositories, credential)
      containers = github_containers_with_branches(compose_data)
      return [] if containers.empty?

      containers.map do |container|
        repository = repositories.detect { |item| item[:clone_url].to_s.start_with?(container[:build][:repository_url]) }
        error_message = I18n.t('compose.repository_not_found', repository_url: container[:build][:repository_url])
        raise UffizziCore::ComposeFile::NotFoundError, error_message if repository.nil?

        branch = begin
          UffizziCore::Github::CredentialService.branch(credential, repository[:id], container[:build][:branch])
        rescue Octokit::NotFound
          nil
        end

        error_message = I18n.t('compose.invalid_branch', branch: container[:build][:branch],
                                                         repository_url: container[:build][:repository_url])
        raise UffizziCore::ComposeFile::NotFoundError, error_message if branch.nil?
      end
    end

    def build_template_attributes(compose_data, source, credentials, project, compose_dependencies = [], compose_repositories = [])
      builder = UffizziCore::ComposeFile::Builders::TemplateBuilderService.new(credentials, project, compose_repositories)

      builder.build_attributes(compose_data, compose_dependencies, source)
    end

    def containers_credentials(compose_data, credentials)
      containers = compose_data[:containers]
      detected_credentials = containers.map do |container|
        UffizziCore::ComposeFile::ContainerService.credential_for_container(container, credentials)
      end

      result = []
      detected_credentials.compact
        .group_by { |credential| credential[:id] }
        .each_pair { |_id, value| result << value.first }
      result
    end

    private

    def process_compose_file(compose_file_form, params)
      credential = compose_file_form.project.account.credentials.github.last
      cli_form = create_cli_form(compose_file_form.content, credential)
      return [compose_file_form, cli_form.errors] if cli_form.invalid?

      dependencies = params[:dependencies].to_a
      compose_data = cli_form.compose_data
      compose_dependencies = build_compose_dependecies(compose_data, compose_file_form.path, dependencies)
      cli_form.compose_dependencies = compose_dependencies

      persist!(compose_file_form, cli_form)
    end

    def create_compose_form(params, kind)
      compose_file_params = params[:compose_file_params]
      compose_file_form = UffizziCore::Api::Cli::V1::ComposeFile::CreateForm.new(compose_file_params)
      compose_file_form.project = params[:project]
      compose_file_form.added_by = params[:user]
      compose_file_form.content = compose_file_params[:content]
      compose_file_form.kind = kind
      payload_dependencies = prepare_compose_file_dependencies(params[:dependencies])
      compose_file_form.payload['dependencies'] = payload_dependencies

      compose_file_form
    end

    def create_update_compose_form(compose_file, params)
      compose_file_form = compose_file.becomes(UffizziCore::Api::Cli::V1::ComposeFile::UpdateForm)
      compose_file_params = params[:compose_file_params]
      compose_file_form.assign_attributes(compose_file_params)
      payload_dependencies = prepare_compose_file_dependencies(params[:dependencies])
      compose_file_form.payload['dependencies'] = payload_dependencies

      compose_file_form
    end

    def create_cli_form(content, credential)
      cli_form = UffizziCore::Api::Cli::V1::ComposeFile::CliForm.new
      cli_form.content = content
      cli_form.credential = credential

      cli_form
    end

    def build_compose_dependecies(compose_data, compose_path, dependencies)
      return [] if dependencies.empty?

      UffizziCore::ComposeFile::DependenciesService.build_dependencies(compose_data, compose_path, dependencies)
    end

    def prepare_compose_file_dependencies(compose_dependencies)
      compose_dependencies.map do |dependency|
        {
          path: dependency[:path],
        }
      end
    end

    def persist!(compose_file_form, cli_form)
      errors = []
      ActiveRecord::Base.transaction do
        if !compose_file_form.save
          errors = compose_file_form.errors
          raise ActiveRecord::Rollback
        end

        config_files_service = UffizziCore::ComposeFile::ConfigFilesService.new(compose_file_form)
        errors = config_files_service.create_config_files(cli_form.compose_dependencies)
        raise ActiveRecord::Rollback if errors.present?

        project = compose_file_form.project
        user = compose_file_form.added_by
        template_service = UffizziCore::ComposeFile::TemplateService.new(cli_form, project, user)
        errors = template_service.create_template(compose_file_form)

        raise ActiveRecord::Rollback if errors.present?
      end
      [compose_file_form, errors]
    end

    def load_compose_data(compose_content)
      begin
        compose_data = YAML.safe_load(compose_content)
      rescue Psych::SyntaxError
        raise UffizziCore::ComposeFile::ParseError, 'Invalid compose file'
      end

      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.unsupported_file') if compose_data.nil?

      compose_data
    end

    def check_config_options_format(compose_data)
      options = UffizziCore::ComposeFile::ConfigOptionService.config_options(compose_data)

      options.each do |option|
        next if UffizziCore::ComposeFile::ConfigOptionService.valid_option_format?(option)

        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_config_option', value: option)
      end
    end

    def github_containers(compose_data)
      compose_data[:containers].select { |container| UffizziCore::ComposeFile::ContainerService.github?(container) }
    end

    def github_containers_with_branches(compose_data)
      github_containers(compose_data).reject { |container| container[:build][:branch].nil? }
    end
  end
end

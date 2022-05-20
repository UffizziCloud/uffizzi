# frozen_string_literal: true

class UffizziCore::ComposeFileService
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
      configs_data = UffizziCore::ComposeFile::Parsers::ConfigsParserService.parse(compose_data['configs'])
      secrets_data = UffizziCore::ComposeFile::Parsers::SecretsParserService.parse(compose_data['secrets'])
      named_volume_names = UffizziCore::ComposeFile::Parsers::VolumesParserService.parse(compose_data['volumes'])
      containers_data = UffizziCore::ComposeFile::Parsers::ServicesParserService.parse(
        compose_data['services'],
        configs_data,
        secrets_data,
        compose_payload,
        named_volume_names,
      )
      continuous_preview_option = UffizziCore::ComposeFile::ConfigOptionService.continuous_preview_option(compose_data)
      continuous_preview_data = UffizziCore::ComposeFile::Parsers::ContinuousPreviewParserService.parse(continuous_preview_option)

      ingress_option = UffizziCore::ComposeFile::ConfigOptionService.ingress_option(compose_data)
      ingress_data = UffizziCore::ComposeFile::Parsers::IngressParserService.parse(ingress_option, compose_data['services'])

      {
        containers: containers_data,
        ingress: ingress_data,
        continuous_preview: continuous_preview_data,
      }
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

    def has_secret?(compose_file, secret)
      containers = compose_file.template.payload['containers_attributes']

      containers.any? { |container| UffizziCore::ComposeFile::ContainerService.has_secret?(container, secret) }
    end

    def update_secret!(compose_file, secret)
      compose_file.template.payload['containers_attributes'].map do |container|
        if UffizziCore::ComposeFile::ContainerService.has_secret?(container, secret)
          container = UffizziCore::ComposeFile::ContainerService.update_secret(container, secret)
        end

        container
      end

      compose_file.template.save!

      compose_file
    end

    def secrets_valid?(compose_file, secrets)
      secret_names = secrets.pluck('name')

      compose_file.template.payload['containers_attributes'].all? do |container|
        container['secret_variables'].all? { |secret| secret_names.include?(secret['name']) }
      end
    end

    def create_temporary_compose(resource_project, current_user, compose_file_params, dependencies)
      create_params = {
        project: resource_project,
        user: current_user,
        compose_file_params: compose_file_params,
        dependencies: dependencies || [],
      }
      kind = UffizziCore::ComposeFile.kind.temporary
      UffizziCore::ComposeFileService.create(create_params, kind)
    end

    private

    def process_compose_file(compose_file_form, params)
      cli_form = UffizziCore::Api::Cli::V1::ComposeFile::CliForm.new
      cli_form.content = compose_file_form.content
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
        compose_data = YAML.safe_load(compose_content, aliases: true)
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
  end
end

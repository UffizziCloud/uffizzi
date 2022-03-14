# frozen_string_literal: true

class UffizziCore::ComposeFile::ServicesOptions::BuildService
  extend UffizziCore::ComposeFile::VariablesService

  class << self
    def parse(build_data, compose_payload)
      return {} if build_data.blank?

      args = parse_args(build_data)

      repository_url, branch, dockerfile_context_path = parse_context(build_data, compose_payload)
      repository_parts = repository_url.split('/').last(2)
      account_name = repository_parts.first
      repository_name = repository_parts.last
      dockerfile = build_data['dockerfile'].blank? ? ::Settings.compose.dockerfile_default_path : build_data['dockerfile']

      {
        repository_url: repository_url,
        account_name: account_name,
        repository_name: repository_name,
        branch: branch,
        dockerfile: dockerfile,
        dockerfile_context_path: dockerfile_context_path,
        args: args,
      }
    end

    private

    def parse_args(build_data)
      args = build_data['args']
      return [] if args.nil?

      case args
      when Array
        args.map { |arg| parse_variable_from_string(arg) }
      when Hash
        args.to_a.map { |arg| parse_variable_from_array(arg) }
      else
        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_type', option: :args)
      end
    end

    def parse_context(build_data, compose_payload)
      if build_data.is_a?(String)
        parse_context_from_inline_syntax(build_data, compose_payload)
      else
        parse_context_from_long_syntax(build_data, compose_payload)
      end
    end

    def parse_repository_url_fragment(fragment)
      branch, dockerfile_context_path = fragment.split(':')

      [branch, dockerfile_context_path]
    end

    def valid_url?(url)
      URI(url).host.present? && URI(url).host =~ /\w+\.\w+/ && URI(url).path.present?
    end

    def parse_context_from_inline_syntax(context, compose_payload)
      if compose_payload[:repository_url].blank?
        raise UffizziCore::ComposeFile::ParseError,
              I18n.t('compose.build_context_unknown_repository')
      end

      repository_url = compose_payload[:repository_url]
      branch = compose_payload[:branch]
      dockerfile_context_path = UffizziCore::ComposeFile::ConfigOptionService.prepare_file_path_value(context)

      [repository_url, branch, dockerfile_context_path]
    end

    def parse_context_from_long_syntax(build_data, compose_payload)
      context = build_data['context']
      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.build_context_no_specified') if context.blank?

      if valid_url?(context)
        uri = URI(context)
        repository_url = "#{uri.scheme}://#{uri.host}#{uri.path}"
        branch, dockerfile_context_path = parse_repository_url_fragment(uri.fragment.to_s)
      else
        repository_url, branch, dockerfile_context_path = parse_context_from_inline_syntax(context, compose_payload)
      end

      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_context', value: context) if repository_url.blank?

      [repository_url, branch, dockerfile_context_path]
    end
  end
end

# frozen_string_literal: true

class UffizziCore::ComposeFile::ServicesOptionsService
  class << self
    def parse(services, global_configs_data, global_secrets_data, compose_payload)
      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.no_services') if services.nil? || services.keys.empty?

      services.keys.map do |service|
        service_data = prepare_service_data(service, services.fetch(service), global_configs_data, global_secrets_data, compose_payload)

        if service_data[:image].blank? && service_data[:build].blank?
          raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.image_build_no_specified', value: service)
        end

        service_data
      end
    end

    private

    def prepare_service_data(service_name, service_data, global_configs_data, global_secrets_data, _compose_payload)
      options_data = {}
      service_data.each_pair do |key, value|
        service_key = key.to_sym

        options_data[service_key] = case service_key
                                    when :image
                                      UffizziCore::ComposeFile::ServicesOptions::ImageService.parse(value)
                                    when :build
                                      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.not_implemented', option: :build)
                                    when :env_file
                                      UffizziCore::ComposeFile::ServicesOptions::EnvFileService.parse(value)
                                    when :environment
                                      UffizziCore::ComposeFile::ServicesOptions::EnvironmentService.parse(value)
                                    when :configs
                                      UffizziCore::ComposeFile::ServicesOptions::ConfigsService.parse(value, global_configs_data)
                                    when :secrets
                                      UffizziCore::ComposeFile::ServicesOptions::SecretsService.parse(value, global_secrets_data)
                                    when :deploy
                                      UffizziCore::ComposeFile::ServicesOptions::DeployService.parse(value)
                                    when :entrypoint
                                      UffizziCore::ComposeFile::ServicesOptions::EntrypointService.parse(value)
                                    when :command
                                      UffizziCore::ComposeFile::ServicesOptions::CommandService.parse(value)
                                    when :'x-uffizzi-continuous-preview', :'x-uffizzi-continuous-previews'
                                      UffizziCore::ComposeFile::ContinuousPreviewOptionsService.parse(value)
        end
      end

      options_data[:container_name] = service_name

      options_data
    end
  end
end

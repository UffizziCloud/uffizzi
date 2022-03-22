# frozen_string_literal: true

class UffizziCore::ComposeFile::ServicesOptions::DeployService
  class << self
    def parse(deploy_data)
      return {} if deploy_data.blank?

      auto = prepare_deploy_auto(deploy_data)
      memory = prepare_memory(deploy_data)

      {
        auto: auto,
        memory: memory,
      }
    end

    private

    def prepare_deploy_auto(deploy_data)
      auto = deploy_data['x-uffizzi-auto-deploy-updates']
      return auto if auto.nil? || auto.in?([true, false])

      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_bool_value', field: :auto, value: auto)
    end

    def prepare_memory(deploy_data)
      memory = deploy_data.dig('resources', 'limits', 'memory')
      return nil if memory.blank?

      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_memory_type', value: memory) unless memory.is_a?(String)

      value, postfix = memory.scan(/^([0-9]+)([a-zA-Z]+)$/).flatten

      if postfix.nil? || !Settings.compose.memory_postfixes.include?(postfix.downcase)
        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_memory_postfix', value: memory)
      end

      {
        value: value.to_i,
        postfix: postfix.downcase,
      }
    end
  end
end

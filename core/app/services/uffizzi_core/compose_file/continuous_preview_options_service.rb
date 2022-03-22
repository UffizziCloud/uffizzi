# frozen_string_literal: true

class UffizziCore::ComposeFile::ContinuousPreviewOptionsService
  class << self
    def parse(continuous_preview_data)
      return {} if continuous_preview_data.nil?

      {
        deploy_preview_when_pull_request_is_opened: trigger_value(continuous_preview_data, 'deploy_preview_when_pull_request_is_opened'),
        delete_preview_when_pull_request_is_closed: trigger_value(continuous_preview_data, 'delete_preview_when_pull_request_is_closed'),
        deploy_preview_when_image_tag_is_created: trigger_value(continuous_preview_data, 'deploy_preview_when_image_tag_is_created'),
        delete_preview_when_image_tag_is_updated: trigger_value(continuous_preview_data, 'delete_preview_when_image_tag_is_updated'),
        delete_preview_after: delete_preview_after_value(continuous_preview_data['delete_preview_after']),
        share_to_github: trigger_value(continuous_preview_data, 'share_to_github'),
      }
    end

    private

    def trigger_value(continuous_preview_data, field)
      value = continuous_preview_data[field]
      return nil if value.nil?
      return value if value.in?([true, false])

      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_bool_value', field: field, value: value)
    end

    def delete_preview_after_value(value)
      return {} if value.blank?
      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_string', option: :delete_preview_after) unless value.is_a?(String)

      hours, postfix = value.scan(/^([0-9]+)([a-zA-Z])$/).flatten

      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_integer', option: :delete_preview_after) if hours.nil?

      formatted_hours = hours.to_i
      if formatted_hours < Settings.compose.delete_after_min_value
        raise UffizziCore::ComposeFile::ParseError,
              I18n.t('compose.invalid_delete_after_min', value: Settings.compose.delete_after_min_value)
      end

      if formatted_hours > Settings.compose.delete_after_max_value
        raise UffizziCore::ComposeFile::ParseError,
              I18n.t('compose.invalid_delete_after_max', value: Settings.compose.delete_after_max_value)
      end

      if postfix.nil? || !Settings.compose.delete_after_postfixes.include?(postfix.downcase)
        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_delete_after_postfix')
      end

      {
        value: formatted_hours,
        postfix: postfix.downcase,
      }
    end
  end
end

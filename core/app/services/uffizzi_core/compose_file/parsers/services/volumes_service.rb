# frozen_string_literal: true

class UffizziCore::ComposeFile::Parsers::Services::VolumesService
  HOST_VOLUME_TYPE = :host
  NAMED_VOLUME_TYPE = :named
  ANONYMOUS_VOLUME_TYPE = :anonymous
  READONLY_OPTION = 'ro'
  READ_WRITE_OPTION = 'rw'

  class << self
    def parse(volumes, named_volumes_names, service_name)
      return [] if volumes.blank?

      volumes.map do |volume|
        volume_data = case volume
                      when String
                        process_short_syntax(volume, named_volumes_names, service_name)
                      when Hash
                        process_long_syntax(volume, named_volumes_names, service_name)
                      else
                        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_type', option: :volumes)
        end

        volume_data
      end
    end

    private

    def process_short_syntax(volume_data, named_volumes_names, service_name)
      volume_parts = volume_data.split(':').map(&:strip)
      has_read_only = volume_parts.include?(READONLY_OPTION)
      part1, part2 = volume_parts
      source_path = part1
      target_path = [READONLY_OPTION, READ_WRITE_OPTION].include?(part2.to_s.downcase) ? nil : part2

      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.volume_prop_is_required', prop_name: 'source') if source_path.blank?

      volume_type = volume_type(source_path, target_path)

      check_named_volume_existence(source_path, target_path, named_volumes_names, service_name) if volume_type == NAMED_VOLUME_TYPE

      {
        source: source_path,
        target: target_path,
        type: volume_type,
        read_only: has_read_only,
      }
    end

    def process_long_syntax(volume_data, named_volumes_names, service_name)
      source_path = volume_data['source'].to_s.strip
      target_path = volume_data['target'].to_s.strip
      has_read_only = volume_data['read_only'].present?

      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.volume_prop_is_required', prop_name: 'source') if source_path.blank?
      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.volume_prop_is_required', prop_name: 'target') if target_path.blank?

      volume_type = volume_type(source_path, target_path)

      check_named_volume_existence(source_path, target_path, named_volumes_names, service_name) if volume_type == NAMED_VOLUME_TYPE

      {
        source: source_path,
        target: target_path,
        type: volume_type,
        read_only: has_read_only,
      }
    end

    def volume_type(source_path, target_path)
      if path?(source_path) && path?(target_path)
        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.volume_type_not_supported', type: HOST_VOLUME_TYPE)
      end

      return ANONYMOUS_VOLUME_TYPE if path?(source_path) && target_path.blank?
      return NAMED_VOLUME_TYPE if source_path.present? && !path?(source_path) && path?(target_path)

      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.volume_path_is_invalid', path: [source_path, target_path].join(':'))
    end

    def path?(path)
      /^(\/|\.\/|~\/)/.match?(path)
    end

    def check_named_volume_existence(source_path, target_path, named_volumes_names, service_name)
      return if named_volumes_names.include?(source_path)

      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.named_volume_not_exists', source_path: source_path,
                                                                                            target_path: target_path,
                                                                                            service_name: service_name)
    end
  end
end

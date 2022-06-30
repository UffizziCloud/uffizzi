# frozen_string_literal: true

class UffizziCore::ComposeFile::Parsers::Services::VolumesParserService
  HOST_VOLUME_TYPE = :host
  NAMED_VOLUME_TYPE = :named
  ANONYMOUS_VOLUME_TYPE = :anonymous
  READONLY_OPTION = 'ro'
  READ_WRITE_OPTION = 'rw'

  class << self
    def parse(volumes, volumes_payload)
      return [] if volumes.blank?

      volumes.map do |volume|
        volume_data = case volume
                      when String
                        process_short_syntax(volume, volumes_payload)
                      when Hash
                        process_long_syntax(volume, volumes_payload)
                      else
                        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_type', option: :volumes)
        end

        volume_data
      end
    end

    private

    def process_short_syntax(volume_data, volumes_payload)
      volume_parts = volume_data.split(':').map(&:strip)
      read_only = volume_parts.last.to_s.downcase == READONLY_OPTION
      part1, part2 = volume_parts
      source_path = part1
      target_path = [READONLY_OPTION, READ_WRITE_OPTION].include?(part2.to_s.downcase) ? nil : part2

      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.volume_prop_is_required', prop_name: 'source') if source_path.blank?

      build_volume_attributes(source_path, target_path, read_only, volumes_payload)
    end

    def process_long_syntax(volume_data, volumes_payload)
      source_path = volume_data['source'].to_s.strip
      target_path = volume_data['target'].to_s.strip
      read_only = volume_data['read_only'].present?

      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.volume_prop_is_required', prop_name: 'source') if source_path.blank?
      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.volume_prop_is_required', prop_name: 'target') if target_path.blank?

      build_volume_attributes(source_path, target_path, read_only, volumes_payload)
    end

    def build_volume_attributes(source_path, target_path, read_only, params = {})
      volume_type = build_volume_type(source_path, target_path)

      if volume_type == NAMED_VOLUME_TYPE
        validate_named_volume(source_path, target_path, params[:named_volumes_names], params[:service_name])
      end

      if volume_type == ANONYMOUS_VOLUME_TYPE
        validate_anonymous_volume(source_path)
      end

      {
        source: source_path,
        target: target_path,
        type: volume_type,
        read_only: read_only,
      }
    end

    def build_volume_type(source_path, target_path)
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

    def validate_named_volume(source_path, target_path, named_volumes_names, service_name)
      if path_has_only_root?(target_path)
        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_volume_destination', spec: "#{source_path}:#{target_path}")
      end

      return if named_volumes_names.include?(source_path)

      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.named_volume_not_exists', source_path: source_path,
                                                                                            target_path: target_path,
                                                                                            service_name: service_name)
    end

    def validate_anonymous_volume(path)
      if path_has_only_root?(path)
        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_volume_destination', spec: path)
      end
    end

    def path_has_only_root?(path)
      path.size == 1 && path.include?('/')
    end
  end
end

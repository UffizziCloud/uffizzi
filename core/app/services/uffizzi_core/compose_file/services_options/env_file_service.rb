# frozen_string_literal: true

class UffizziCore::ComposeFile::ServicesOptions::EnvFileService
  class << self
    def parse(env_file)
      env_files = case env_file
                  when String
                    [prepare_file_path(env_file)]
                  when Array
                    env_file.map { |env_file_path| prepare_file_path(env_file_path) }
                  else
                    raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_type', option: :env_file)
      end

      check_duplicates(env_files)

      env_files
    end

    private

    def prepare_file_path(env_file_path)
      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.empty_env_file') if env_file_path.blank?

      UffizziCore::ComposeFile::ConfigOptionService.prepare_file_path_value(env_file_path)
    end

    def check_duplicates(env_files)
      return if env_files.uniq.length == env_files.length

      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.env_file_duplicates', values: env_files)
    end
  end
end

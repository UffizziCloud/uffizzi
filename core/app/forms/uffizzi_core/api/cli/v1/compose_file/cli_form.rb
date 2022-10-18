# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::ComposeFile::CliForm
  include UffizziCore::ApplicationFormWithoutActiveRecord

  attribute :compose_content_data, Hash
  attribute :compose_data, Hash
  attribute :compose_dependencies, Array
  attribute :compose_repositories, Array
  attribute :content, String
  attribute :source_kind, Symbol
  attribute :compose_file, UffizziCore::ComposeFile

  validates :content, presence: true
  validates :compose_file, presence: true
  validate :check_compose_parsed_data, if: -> { errors[:content].empty? }

  def check_compose_parsed_data
    compose_content = Base64.decode64(content)
    compose_payload = { compose_file: compose_file }
    self.compose_data = UffizziCore::ComposeFileService.parse(compose_content, compose_payload)
  rescue UffizziCore::ComposeFile::ParseError => e
    errors.add(:content, e.message)
  end
end

# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::ComposeFile::CliForm
  include UffizziCore::ApplicationFormWithoutActiveRecord

  attribute :compose_content_data, Hash
  attribute :compose_data, Hash
  attribute :compose_dependencies, Array
  attribute :compose_repositories, Array
  attribute :content, String
  attribute :source_kind, Symbol

  validates :content, presence: true

  validate :check_compose_parsed_data, if: -> { errors[:content].empty? }

  def check_compose_parsed_data
    compose_content = Base64.decode64(content)
    self.compose_data = UffizziCore::ComposeFileService.parse(compose_content)
  rescue UffizziCore::ComposeFile::ParseError => e
    errors.add(:content, e.message)
  end
end

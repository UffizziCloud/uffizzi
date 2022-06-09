# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::ComposeFile::CreateForm < UffizziCore::ComposeFile
  include UffizziCore::ApplicationForm

  permit :source, :path, :content

  validates :source, presence: true
  validates :path, presence: true
  validates :content, presence: true
end

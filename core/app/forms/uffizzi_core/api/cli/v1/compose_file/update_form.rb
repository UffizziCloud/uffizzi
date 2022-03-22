# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::ComposeFile::UpdateForm < UffizziCore::ComposeFile
  include UffizziCore::ApplicationForm

  permit :content, :source, :path

  validates :content, presence: true
end

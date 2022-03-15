# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::ComposeFile::CreateForm < UffizziCore::ComposeFile
  include UffizziCore::ApplicationForm

  permit :source, :path, :content

  validates :source, presence: true,
                     uniqueness: { scope: :project_id, message: 'A compose file with the same source already exists for this project' },
                     if: -> { kind.main? }
  validates :path, presence: true
  validates :content, presence: true
end

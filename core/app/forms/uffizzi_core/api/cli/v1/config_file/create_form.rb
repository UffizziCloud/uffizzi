# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::ConfigFile::CreateForm < UffizziCore::ConfigFile
  include UffizziCore::ApplicationForm

  permit :filename, :kind, :payload

  validates :filename, presence: true
  validates :kind, presence: true
  validates :payload, presence: true
end

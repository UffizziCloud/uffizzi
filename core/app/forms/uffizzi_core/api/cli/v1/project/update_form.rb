# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Project::UpdateForm < UffizziCore::Project
  include UffizziCore::ApplicationForm

  permit :name, :slug, :description

  validates :name, presence: true, uniqueness: { scope: :account }
  validates :slug, presence: true, uniqueness: true
end

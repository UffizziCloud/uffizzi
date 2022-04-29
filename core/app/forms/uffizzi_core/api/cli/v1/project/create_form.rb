# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Project::CreateForm < UffizziCore::Project
  include UffizziCore::ApplicationForm

  permit :name, :slug, :description
end

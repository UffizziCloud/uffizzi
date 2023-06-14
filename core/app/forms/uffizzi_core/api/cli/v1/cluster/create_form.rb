# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Cluster::CreateForm < UffizziCore::Cluster
  include UffizziCore::ApplicationForm

  permit :name
end

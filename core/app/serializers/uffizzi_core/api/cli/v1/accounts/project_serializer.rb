# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Accounts::ProjectSerializer < UffizziCore::BaseSerializer
  type :project

  attributes :name,
             :slug,
             :account_id,
             :description,
             :created_at
end

# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::ShortProjectSerializer < UffizziCore::BaseSerializer
  type :project
  belongs_to :account, serializer: UffizziCore::Api::Cli::V1::ProjectSerializer::AccountSerializer

  # account_id supports CLI versions < 2.0.5
  attributes :name, :slug, :account_id
end

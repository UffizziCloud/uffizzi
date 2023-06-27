# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::AccountSerializer < UffizziCore::BaseSerializer
  type :account

  has_many :projects

  attributes :id, :name
end

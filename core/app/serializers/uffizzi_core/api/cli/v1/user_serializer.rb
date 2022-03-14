# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::UserSerializer < UffizziCore::BaseSerializer
  type :user

  has_many :accounts
end

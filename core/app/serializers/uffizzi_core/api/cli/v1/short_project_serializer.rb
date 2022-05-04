# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::ShortProjectSerializer < UffizziCore::BaseSerializer
  type :project

  attributes :name, :slug
end

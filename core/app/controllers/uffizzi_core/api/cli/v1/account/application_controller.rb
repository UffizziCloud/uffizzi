# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Account::ApplicationController < UffizziCore::Api::Cli::V1::ApplicationController
  def resource_account
    @resource_account ||= current_user.organizational_account
  end
end

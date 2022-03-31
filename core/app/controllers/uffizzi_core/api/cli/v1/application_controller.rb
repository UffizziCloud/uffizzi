# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::ApplicationController < UffizziCore::ApplicationController
  before_action :authenticate_request!
end

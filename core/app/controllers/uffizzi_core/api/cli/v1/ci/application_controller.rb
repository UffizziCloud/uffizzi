# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Ci::ApplicationController < UffizziCore::Api::Cli::V1::ApplicationController
  before_action :authenticate_request!
end

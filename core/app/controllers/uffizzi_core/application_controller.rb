# frozen_string_literal: true

class UffizziCore::ApplicationController < ActionController::Base
  include UffizziCore::ResponseService
  include UffizziCore::AuthManagement

  DEFAULT_PAGE = 1
  DEFAULT_PER_PAGE = 20

  protect_from_forgery with: :exception
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  before_action :authenticate_request!
  skip_before_action :verify_authenticity_token
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  respond_to :json

  def policy_context
    UffizziCore::BaseContext.new(current_user, user_access_module, params)
  end

  def self.responder
    UffizziCore::JsonResponder
  end

  def render_not_found
    render json: { errors: { title: ['Resource Not Found'] } }, status: :not_found
  end

  def render_errors(errors)
    json = { errors: errors }

    render json: json, status: :unprocessable_entity
  end

  def q_param
    params[:q] || ActionController::Parameters.new
  end

  def page
    params[:page] || DEFAULT_PAGE
  end

  def per_page
    params[:per_page] || DEFAULT_PER_PAGE
  end
end

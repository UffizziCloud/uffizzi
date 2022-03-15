# frozen_string_literal: true

Rails.application.routes.draw do
  mount UffizziCore::Engine => '/'
  health_check_routes
end

# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::AccountSerializer < UffizziCore::BaseSerializer
  include UffizziCore::DependencyInjectionConcern
  include_module_if_exists('UffizziCore::Api::Cli::V1::AccountSerializerModule')

  type :account

  has_many :projects

  attributes :id, :name, :api_url, :vclusters_controller_url

  def api_url
    Settings.domain
  end

  def vclusters_controller_url
    controller_settings_service.vcluster_settings_by_account(object).url
  end
end

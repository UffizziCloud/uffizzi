# frozen_string_literal: true

class UffizziCore::ControllerSettingsService
  class << self
    def vcluster_settings_by_vcluster(_cluster)
      Settings.vcluster_controller
    end

    def vcluster_settings_by_account(_account)
      Settings.vcluster_controller
    end

    def deployment_settings_by_deployment(_deployment)
      Settings.controller.deep_dup.tap do |s|
        s.managed_dns_zone = Settings.app.managed_dns_zone
      end
    end
  end
end

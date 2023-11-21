# frozen_string_literal: true

class UffizziCore::ControllerSettingsService
  class << self
    def vcluster(_cluster)
      Settings.vcluster_controller
    end

    def deployment(_cluster)
      Settings.controller.deep_dup.tap do |s|
        s.managed_dns_zone = Settings.app.managed_dns_zone
      end
    end
  end
end

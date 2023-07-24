# frozen_string_literal: true

class UffizziCore::ControllerSettingsService
  class << self
    def vcluster(_cluster)
      Settings.vcluster_controller
    end
  end
end

# frozen_string_literal: true

class UffizziCore::Build::MonitorJob < UffizziCore::ApplicationJob
  sidekiq_options queue: :deployments, retry: 5

  def perform(build_id)
    build = UffizziCore::Build.find(build_id)

    UffizziCore::BuildService.monitor_build(build)
  end
end

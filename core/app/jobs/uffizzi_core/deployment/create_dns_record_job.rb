# frozen_string_literal: true

class UffizziCore::Deployment::CreateDnsRecordJob < UffizziCore::ApplicationJob
  sidekiq_options queue: :deployments, retry: 5

  def perform(deployment_id)
    Rails.logger.info("DEPLOYMENT_PROCESS deployment_id=#{deployment_id} CreateDnsRecordJob")

    deployment = UffizziCore::Deployment.find(deployment_id)

    UffizziCore::GoogleCloud::DnsService.create_dns_record(deployment)
  end
end

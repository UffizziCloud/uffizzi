# frozen_string_literal: true

require 'resolv'

class UffizziCore::GoogleCloud::DnsService
  TTL = 60

  class << self
    def create_dns_record(deployment)
      ingress_endpoint = UffizziCore::IngressService.ingress_endpoint
      preview_url = UffizziCore::DeploymentService.build_preview_url(deployment)

      if valid_ip?(ingress_endpoint)
        create_a_record(preview_url, ingress_endpoint)
      else
        create_cname_record(preview_url, ingress_endpoint)
      end
    end

    def delete_dns_record(record_url)
      client.delete_dns_record(record_url)
    end

    def dns_record_exists?(record_url)
      client.dns_record_exists?(record_url)
    end

    private

    def create_a_record(record_url, ip)
      client.create_dns_record(record_url, UffizziCore::GoogleCloudDnsClient::A_RECORD_TYPE, TTL, ip)
    end

    def create_cname_record(record_url, canonical_name)
      client.create_dns_record(record_url, UffizziCore::GoogleCloudDnsClient::CNAME_RECORD_TYPE, TTL, "#{canonical_name}.")
    end

    def client
      @client ||= UffizziCore::GoogleCloudDnsClient.new(Settings.dns_zone.name)
    end

    def valid_ip?(ip)
      !!(ip =~ Resolv::IPv4::Regex)
    end
  end
end

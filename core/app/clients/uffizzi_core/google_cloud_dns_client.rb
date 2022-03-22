# frozen_string_literal: true

class UffizziCore::GoogleCloudDnsClient
  A_RECORD_TYPE = 'A'
  CNAME_RECORD_TYPE = 'CNAME'

  def initialize(zone_name)
    @client = Google::Cloud::Dns.new
    @zone_name = zone_name
  end

  def create_dns_record(subdomain, type, ttl, data)
    dns_zone.update do |tx|
      tx.add(subdomain, type, ttl, data)
    end
  end

  def delete_dns_record(subdomain)
    dns_record = record(subdomain)

    return nil if dns_record.nil?

    dns_zone.update do |tx|
      tx.remove(subdomain, dns_record.type)
    end
  end

  def dns_record_exists?(subdomain)
    dns_record = record(subdomain)

    !dns_record.nil?
  end

  def record(subdomain)
    dns_zone.records("#{subdomain}.")&.first
  end

  def dns_zone
    @client.zone(@zone_name)
  end
end

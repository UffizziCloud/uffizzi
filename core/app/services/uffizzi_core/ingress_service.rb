# frozen_string_literal: true

class UffizziCore::IngressService
  class << self
    def ingress_endpoint
      ingress_service = controller_client.ingress_service.result
      ingress = ingress_service.status.load_balancer.ingress
      return nil unless ingress.present?

      ingress_data = ingress.first
      ip = ingress_data.ip
      hostname = ingress_data.hostname

      ip.presence || hostname.presence
    end

    private

    def controller_client
      UffizziCore::ControllerClient.new
    end
  end
end

# frozen_string_literal: true

class UffizziCore::LogsService
  NOT_ALLOWED_SYMBOLS_IN_NAME_REGEX = /[^a-zA-Z0-9-]/.freeze

  class << self
    def fetch_container_logs(container, query = {}, pretty_format=false)
      response = request_logs(container, query).result || {}
      response = Hashie::Mash.new(response)
      return { logs: response.logs } unless pretty_format

      logs = response.logs.map do |item|
        timestamp, *payload = item.split(' ')
        { timestamp: timestamp&.gsub('T', ' ')&.gsub('Z', ' UTC'), payload: payload.join(' ') }
      end

      {
        logs: logs,
      }
    end

    private

    def request_logs(container, query)
      deployment = container.deployment

      controller_client.deployment_container_logs(
        deployment_id: deployment.id,
        container_name: UffizziCore::ContainerService.pod_name(container),
        limit: query[:limit],
        previous: query[:previous] || false,
      )
    end

    def controller_client
      UffizziCore::ControllerClient.new
    end
  end
end

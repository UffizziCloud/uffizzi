# frozen_string_literal: true

class UffizziCore::LogsService
  NOT_ALLOWED_SYMBOLS_IN_NAME_REGEX = /[^a-zA-Z0-9-]/.freeze
  DEFAULT_LOGS_LIMIT = 1000

  class << self
    def fetch_container_logs(container, query = {})
      response = request_logs(container, query).result || {}
      response = Hashie::Mash.new(response)
      logs = response.logs || []

      {
        logs: format_logs(logs),
      }
    end

    private

    def request_logs(container, query)
      deployment = container.deployment

      controller_client.deployment_container_logs(
        deployment_id: deployment.id,
        container_name: UffizziCore::ContainerService.pod_name(container),
        limit: query[:limit] || DEFAULT_LOGS_LIMIT,
        previous: query[:previous] || false,
      )
    end

    def format_logs(logs)
      logs.map do |item|
        timestamp, *payload = item.split
        formatted_timestamp = timestamp.present? ? timestamp.to_time(:utc).strftime('%Y-%m-%d %H:%M:%S.%L %Z') : nil
        { timestamp: formatted_timestamp, payload: payload.join(' ') }
      end
    end

    def controller_client
      UffizziCore::ControllerClient.new(Settings.controller)
    end
  end
end

# frozen_string_literal: true

class UffizziCore::ControllerClient
  attr_accessor :connection

  def initialize
    @connection = build_connection
  end

  def apply_config_file(deployment_id:, config_file_id:, body:)
    connection.post("/deployments/#{deployment_id}/config_files/#{config_file_id}", body)
  end

  def deployment(deployment_id:)
    get("/deployments/#{deployment_id}")
  end

  def create_deployment(deployment_id:, body:)
    connection.post("/deployments/#{deployment_id}", body)
  end

  def update_deployment(deployment_id:, body:)
    connection.put("/deployments/#{deployment_id}", body)
  end

  def delete_deployment(deployment_id:)
    connection.delete("/deployments/#{deployment_id}")
  end

  def deployment_containers(deployment_id:)
    get("/deployments/#{deployment_id}/containers")
  end

  def ingress_service
    get('/default_ingress/service')
  end

  def deploy_containers(deployment_id:, body:)
    connection.post("/deployments/#{deployment_id}/containers", body)
  end

  def deployment_containers_metrics(deployment_id:)
    get("/deployments/#{deployment_id}/containers/metrics")
  end

  def deployment_container_logs(deployment_id:, container_name:, limit:)
    get("/deployments/#{deployment_id}/containers/#{container_name}/logs?limit=#{limit}")
  end

  def deployment_containers_events(deployment_id:)
    events = get("/deployments/#{deployment_id}/containers/events").result.items
    pods_events = events.select { |event| event.involved_object.kind == 'Pod' }
    pods_events.map do |event|
      { first_timestamp: event.first_timestamp, last_timestamp: event.last_timestamp, reason: event.reason, message: event.message }
    end
  end

  def nodes
    get('/nodes')
  end

  def apply_credential(deployment_id:, body:)
    connection.post("/deployments/#{deployment_id}/credentials", body)
  end

  def delete_credential(deployment_id:, credential_id:)
    connection.delete("/deployments/#{deployment_id}/credentials/#{credential_id}")
  end

  def get_deployments_usage_metrics_containers(deployment_ids:, begin_at:, end_at:)
    query_params = {
      deployment_ids: deployment_ids,
      begin_at: begin_at,
      end_at: end_at,
    }
    get('/deployments/usage_metrics/containers', query_params)
  end

  private

  def get(url, params = {})
    response = connection.get(url, params)
    body = response.body
    underscored_body = UffizziCore::Converters.deep_underscore_keys(body)

    RequestResult.quiet.new(code: response.status, result: underscored_body)
  end

  def build_connection
    controller = Settings.controller
    login = controller.login
    password = controller.password
    url = controller.url
    connection = controller.connection
    handled_exceptions = Faraday::Request::Retry::DEFAULT_EXCEPTIONS + [Faraday::ConnectionFailed]

    Faraday.new(url) do |conn|
      conn.options.timeout = connection.timeout
      conn.options.open_timeout = connection.open_timeout
      conn.request(:basic_auth, login, password)
      conn.request(:json)
      conn.request(:retry,
                   max: connection.retires_count,
                   interval: connection.next_retry_timeout_seconds,
                   exceptions: handled_exceptions)
      conn.response(:json)
      conn.adapter(Faraday.default_adapter)
    end
  end
end

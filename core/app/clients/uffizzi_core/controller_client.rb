# frozen_string_literal: true

class UffizziCore::ControllerClient
  class ConnectionError < StandardError; end

  attr_accessor :connection

  def initialize(connection_settings)
    @connection = build_connection(connection_settings)
  end

  def apply_config_file(deployment_id:, config_file_id:, body:)
    connection.post("/deployments/#{deployment_id}/config_files/#{config_file_id}", body)
  end

  def deployment_containers(deployment_id:)
    get("/deployments/#{deployment_id}/containers")
  end

  def deploy_containers(deployment_id:, body:)
    connection.post("/deployments/#{deployment_id}/containers", body)
  end

  def deployment_containers_metrics(deployment_id:)
    get("/deployments/#{deployment_id}/containers/metrics")
  end

  def deployment_container_logs(deployment_id:, container_name:, limit:, previous:)
    get("/deployments/#{deployment_id}/containers/#{container_name}/logs?limit=#{limit}&previous=#{previous}")
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

  def create_namespace(body:)
    post('/namespaces', body)
  end

  def namespace(namespace:)
    get("/namespaces/#{namespace}")
  end

  def delete_namespace(namespace:)
    connection.delete("/namespaces/#{namespace}")
  end

  def create_cluster(namespace:, body:)
    post("/namespaces/#{namespace}/cluster", body)
  end

  def show_cluster(namespace:, name:)
    get("/namespaces/#{namespace}/cluster/#{name}")
  end

  def patch_cluster(name:, namespace:, body:)
    patch("/namespaces/#{namespace}/cluster/#{name}", body)
  end

  def ingresses(namespace:)
    get("/namespaces/#{namespace}/ingresses")
  end

  private

  def get(url, params = {})
    make_request(:get, url, params)
  end

  def post(url, params = {})
    make_request(:post, url, params)
  end

  def patch(url, params = {})
    make_request(:patch, url, params)
  end

  def make_request(method, url, params)
    response = connection.send(method, url, params)
    body = response.body
    underscored_body = UffizziCore::Converters.deep_underscore_keys(body)

    RequestResult.quiet.new(code: response.status, result: underscored_body)
  rescue Faraday::ServerError
    raise ConnectionError
  end

  def build_connection(settings)
    connection = settings.connection
    handled_exceptions = Faraday::Request::Retry::DEFAULT_EXCEPTIONS + [Faraday::ConnectionFailed]

    Faraday.new(settings.url) do |conn|
      conn.options.timeout = connection.timeout
      conn.options.open_timeout = connection.open_timeout
      conn.request(:basic_auth, settings.login, settings.password)
      conn.request(:json)
      conn.request(:retry,
                   max: connection.retires_count,
                   interval: connection.next_retry_timeout_seconds,
                   exceptions: handled_exceptions)
      conn.response(:json)
      conn.response(:raise_error)
      conn.adapter(Faraday.default_adapter)
    end
  end
end

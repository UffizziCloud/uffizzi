# frozen_string_literal: true

module UffizziCore::ControllerStubSupport
  def stub_controller_create_deployment_request
    uri = %r{#{Regexp.quote(Settings.controller.url.to_s)}/deployments/[0-9]*$}

    stub_request(:post, uri)
  end

  def stub_controller_apply_credential
    uri = %r{#{Regexp.quote(Settings.controller.url.to_s)}/deployments/[0-9]*/credentials}

    stub_request(:post, uri)
  end

  def stub_put_controller_deployment_request(deployment)
    uri = "#{Settings.controller.url}/deployments/#{deployment.id}"

    stub_request(:put, uri)
  end

  def stub_controller_get_deployment_request(deployment, data = nil)
    uri = "#{Settings.controller.url}/deployments/#{deployment.id}"

    stub_request(:get, uri).to_return(status: 200, body: data.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def stub_controller_get_deployment_request_any(data = nil)
    uri = %r{#{Regexp.quote(Settings.controller.url.to_s)}/deployments/[0-9]*}

    stub_request(:get, uri).to_return(status: 200, body: data.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def stub_delete_controller_deployment_request(deployment)
    uri = "#{Settings.controller.url}/deployments/#{deployment.id}"

    stub_request(:delete, uri)
  end

  def stub_controller_containers_request(deployment, data = nil)
    uri = "#{Settings.controller.url}/deployments/#{deployment.id}/containers"

    stub_request(:get, uri).to_return(status: 200, body: data.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def stub_controller_nodes_request
    uri = "#{Settings.controller.url}/nodes"

    stub_request(:get, uri)
  end

  def stub_deploy_containers_request(deployment)
    uri = "#{Settings.controller.url}/deployments/#{deployment.id}/containers"

    stub_request(:post, uri)
  end

  def stub_apply_config_file_request(deployment, config_file)
    uri = "#{Settings.controller.url}/deployments/#{deployment.id}/config_files/#{config_file.id}"

    stub_request(:post, uri)
  end

  def stub_apply_config_file_request_with_expected(deployment, config_file, expected_request)
    uri = "#{Settings.controller.url}/deployments/#{deployment.id}/config_files/#{config_file.id}"

    stub_request(:post, uri).with do |req|
      actual_body = JSON.parse(req.body).deep_symbolize_keys.deep_sort
      expected_body = expected_request.deep_symbolize_keys.deep_sort

      is_equal = actual_body == expected_body

      ap(HashDiff.diff(actual_body, expected_body)) unless is_equal

      is_equal
    end
  end

  def stub_controller_get_deployment_events(deployment, body)
    uri = "#{Settings.controller.url}/deployments/#{deployment.id}/containers/events"

    stub_request(:get, uri).to_return(status: 200, body: body.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def stub_container_log_request(deployment_id, pod_name, limit, data)
    uri = "#{Settings.controller.url}/deployments/#{deployment_id}/containers/#{pod_name}/logs?limit=#{limit}"

    stub_request(:get, uri).to_return(status: 200, body: data.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def stub_deploy_containers_request_with_expected(deployment, expected_request)
    uri = "#{Settings.controller.url}/deployments/#{deployment.id}/containers"

    stub_request(:post, uri).with do |req|
      actual_body = JSON.parse(req.body).deep_symbolize_keys.deep_sort
      expected_body = expected_request.deep_symbolize_keys.deep_sort

      is_equal = actual_body == expected_body

      ap(HashDiff.diff(actual_body, expected_body)) unless is_equal

      is_equal
    end
  end
end

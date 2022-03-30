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

  def stub_controller_get_deployment_events(deployment, body)
    uri = "#{Settings.controller.url}/deployments/#{deployment.id}/containers/events"

    stub_request(:get, uri).to_return(status: 200, body: body.to_json, headers: { 'Content-Type' => 'application/json' })
  end
end

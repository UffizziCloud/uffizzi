# frozen_string_literal: true

module UffizziCore::DockerRegistryStubSupport
  def stub_docker_registry_manifests(registry_url, image, tag, headers = {}, body = {})
    uri = "#{registry_url}/v2/#{image}/manifests/#{tag}"

    stub_request(:get, uri).to_return(status: 200, headers: headers, body: body.to_json)
  end
end

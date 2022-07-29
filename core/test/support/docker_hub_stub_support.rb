# frozen_string_literal: true

module UffizziCore::DockerHubStubSupport
  API_URL = 'https://hub.docker.com/v2'
  AUTH_URL = 'https://auth.docker.io'

  def stub_dockerhub_login
    response = { token: 'mytoken' }
    uri = %r{#{API_URL}/users/login/}

    stub_request(:post, uri).to_return(status: 200, body: response.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def stub_dockerhub_login_fail(data)
    uri = %r{#{API_URL}/users/login/}

    stub_request(:post, uri).to_return(status: 401, body: data.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def stub_dockerhub_auth_for_digest(repository)
    response = { token: 'mytoken' }
    url = %r{#{AUTH_URL}.+scope=repository:#{repository}:pull&service=registry[.]docker[.]io.+}
    stub_request(:get, url).to_return(status: 200, body: response.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def stub_dockerhub_get_digest(image, tag, data)
    url = "https://index.docker.io/v2/#{image}/manifests/#{tag}"
    stub_request(:get, url).to_return(status: 200, body: data[:body].to_json, headers: data[:headers])
  end

  def stub_dockerhub_api_tokens(data)
    uri = "#{API_URL}/api_tokens"

    stub_request(:post, uri).to_return(status: 201, body: data.to_json)
  end
end

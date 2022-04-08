# frozen_string_literal: true

module UffizziCore::GithubContainerRegistryStubSupport
  def stub_github_container_registry_access_token(registry_url, response)
    service = URI.parse(registry_url).hostname
    uri = "#{registry_url}/token?service=#{service}"

    stub_request(:get, uri).to_return(status: 200, body: response.to_json, headers: { 'Content-Type' => 'application/json' })
  end
end

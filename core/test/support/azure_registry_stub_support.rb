# frozen_string_literal: true

module UffizziCore::AzureRegistryStubSupport
  def stub_azure_registry_oauth2_token(registry_url, response, code = 200)
    service = URI.parse(registry_url).hostname
    uri = "#{registry_url}/oauth2/token?service=#{service}"

    stub_request(:get, uri).to_return(status: code, body: response.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def stub_azure_registry_manifests(registry_url, image, tag, headers, body)
    uri = "#{registry_url}/v2/#{image}/manifests/#{tag}"

    stub_request(:get, uri).to_return(status: 200, headers: headers, body: body.to_json)
  end
end

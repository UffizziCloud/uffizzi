# frozen_string_literal: true

module UffizziCore::GoogleRegistryStubSupport
  REGISTRY_URL = 'https://gcr.io'

  def stub_google_registry_token(response, code = 200)
    service = URI.parse(REGISTRY_URL).hostname
    uri = "#{REGISTRY_URL}/v2/token?service=#{service}"

    stub_request(:get, uri).to_return(status: code, body: response.to_json, headers: {})
  end

  def stub_google_registry_manifests(image, tag, headers, body)
    uri = "#{REGISTRY_URL}/v2/#{image}/manifests/#{tag}"

    stub_request(:get, uri).to_return(status: 200, headers: headers, body: body.to_json)
  end
end

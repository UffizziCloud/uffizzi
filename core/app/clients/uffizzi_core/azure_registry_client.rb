# frozen_string_literal: true

class UffizziCore::AzureRegistryClient
  attr_accessor :connection, :token, :registry_url

  def initialize(registry_url:, username:, password:)
    @registry_url = registry_url
    @connection = build_connection(registry_url, username, password)
    @token = oauth2_token&.result&.access_token
  end

  def manifests(image:, tag:)
    url = "/v2/#{image}/manifests/#{tag}"
    response = connection.get(url)

    RequestResult.quiet.new(result: response.body, headers: response.headers)
  end

  def oauth2_token
    service = URI.parse(registry_url).hostname
    url = "/oauth2/token?service=#{service}"

    response = connection.get(url, {})

    RequestResult.new(result: response.body)
  end

  def authenticated?
    token.present?
  end

  private

  def build_connection(registry_url, username, password)
    Faraday.new(registry_url) do |faraday|
      faraday.request(:basic_auth, username, password)
      faraday.request(:json)
      faraday.response(:json)
      faraday.response(:raise_error)
      faraday.adapter(Faraday.default_adapter)
    end
  end
end

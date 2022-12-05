# frozen_string_literal: true

class UffizziCore::GoogleRegistryClient
  attr_accessor :connection, :token, :registry_url

  def initialize(registry_url:, username:, password:)
    @registry_url = registry_url
    @connection = build_connection(registry_url, username, password)
    @token = access_token&.result&.token
  end

  def manifests(image:, tag:)
    url = "/v2/#{image}/manifests/#{tag}"
    response = connection.get(url)

    RequestResult.quiet.new(result: response.body, headers: response.headers)
  end

  def access_token
    service = URI.parse(registry_url).hostname
    url = "/v2/token?service=#{service}"

    response = connection.get(url, {})

    RequestResult.new(result: response.body)
  end

  def authenticated?
    token.present?
  end

  private

  def build_connection(registry_url, username, password)
    connection = Faraday.new(registry_url) do |faraday|
      faraday.request(:basic_auth, username, password)
      faraday.request(:json)
      faraday.response(:json)
      faraday.response(:raise_error)
      faraday.adapter(Faraday.default_adapter)
    end

    connection.extend(UffizziCore::HttpRequestDecorator)
  end
end

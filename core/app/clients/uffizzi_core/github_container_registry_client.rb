# frozen_string_literal: true

class UffizziCore::GithubContainerRegistryClient
  attr_accessor :token, :registry_url

  def initialize(registry_url:, username:, password:)
    @registry_url = registry_url
    @username = username
    @password = password
    @token = access_token&.result&.token
  end

  def access_token
    service = URI.parse(registry_url).hostname
    url = "/token?service=#{service}"

    response = connection.get(url, {})

    RequestResult.new(result: response.body)
  end

  def authenticated?
    token.present?
  end

  def manifests(image:, tag:)
    url = "/v2/#{@username}/#{image}/manifests/#{tag}"
    response = token_connection.get(url)

    RequestResult.quiet.new(result: response.body, headers: response.headers)
  end

  private

  def connection
    Faraday.new(registry_url) do |faraday|
      faraday.request(:basic_auth, @username, @password)
      faraday.request(:json)
      faraday.response(:json)
      faraday.response(:raise_error)
      faraday.adapter(Faraday.default_adapter)
    end
  end

  def token_connection
    Faraday.new(registry_url) do |faraday|
      faraday.request(:authorization, 'Bearer', token)
      faraday.request(:json)
      faraday.response(:json)
      faraday.response(:raise_error)
      faraday.adapter(Faraday.default_adapter)
    end
  end
end

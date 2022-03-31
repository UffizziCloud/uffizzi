# frozen_string_literal: true

class UffizziCore::GithubContainerRegistryClient
  attr_accessor :connection, :token, :registry_url

  def initialize(registry_url:)
    @registry_url = "https://#{registry_url}"
    @connection = build_connection(@registry_url)
  end

  def manifests(image:, tag:)
    url = "/v2/#{image}/manifests/#{tag}"
    response = connection.get(url)

    RequestResult.quiet.new(result: response.body, headers: response.headers)
  end

  private

  def build_connection(registry_url)
    Faraday.new(registry_url) do |conn|
      conn.request(:token_auth, ENV['GITHUB_ACCESS_TOKEN'])
      conn.request(:json)
      conn.response(:json)
      conn.adapter(Faraday.default_adapter)
    end
  end
end

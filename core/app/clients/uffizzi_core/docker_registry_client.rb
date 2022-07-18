# frozen_string_literal: true

class UffizziCore::DockerRegistryClient
  def initialize(credentials)
    @registry_url = credentials.registry_url
    @connection = build_connection(@registry_url, credentials.username, credentials.password)
  end

  def authenticated?
    response = @connection.head('/v2/')
    response.status == 200
  end

  private

  def build_connection(registry_url, username, password)
    #TODO: enable ssl verification after tests
    Faraday.new(registry_url, ssl: {verify: false}) do |conn|
      conn.request(:basic_auth, username, password)
      conn.request(:json)
      conn.response(:json)
      conn.adapter(Faraday.default_adapter)
    end
  end
end

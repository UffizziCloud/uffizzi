# frozen_string_literal: true

class UffizziCore::DockerHubClient
  attr_accessor :connection, :jwt, :credential

  BASE_URL = 'https://hub.docker.com'

  def initialize(credential = nil)
    @connection = build_connection
    @credential = credential
    return unless credential

    @jwt = authentificate
  end

  def authentificate
    params = { username: credential.username, password: credential.password }
    url = "#{BASE_URL}/v2/users/login/"
    response = connection.post(url, params)
    request_result = RequestResult.new(result: response.body)
    request_result.result.token
  rescue NoMethodError
    nil
  end

  def public_images(q:, page: 1, per_page: 25)
    url = "#{BASE_URL}/api/content/v1/products/search"
    params = { page_size: per_page, q: q, type: :image, page: page }
    response = connection.get(url, params) do |request|
      request.headers['Search-Version'] = 'v3'
    end
    RequestResult.new(result: response.body)
  end

  def private_images(account:, page: 1, per_page: 25)
    raise NotAuthorizedError if !authentificated? || account.empty?

    url =  BASE_URL + "/v2/repositories/#{account}/"
    params = { page_size: per_page, page: page }
    response = connection.get(url, params) do |request|
      request.headers['Authorization'] = "JWT #{jwt}"
    end
    RequestResult.new(result: response.body)
  end

  def accounts
    raise NotAuthorizedError if !authentificated?

    url = "#{BASE_URL}/v2/repositories/namespaces/"
    response = connection.get(url) do |request|
      request.headers['Authorization'] = "JWT #{jwt}"
    end
    RequestResult.new(result: response.body)
  end

  def metadata(namespace:, image:)
    url = BASE_URL + "/v2/repositories/#{namespace}/#{image}/"
    response = connection.get(url) do |request|
      request.headers['Authorization'] = "JWT #{jwt}"
    end
    RequestResult.quiet.new(result: response.body)
  end

  def tags(namespace:, image:, q: '', page: 1, per_page: 10)
    url = BASE_URL + "/v2/repositories/#{namespace}/#{image}/tags"
    params = { page_size: per_page, page: page, name: q }
    response = connection.get(url, params) do |request|
      request.headers['Authorization'] = "JWT #{jwt}"
    end
    RequestResult.quiet.new(result: response.body)
  end

  def digest(image:, tag:, token:)
    url = "https://index.docker.io/v2/#{image}/manifests/#{tag}"
    response = connection.get(url) do |request|
      request.headers['Accept'] = 'application/vnd.docker.distribution.manifest.v2+json'
      request.headers['Authorization'] = "Bearer #{token}"
    end

    RequestResult.quiet.new(result: response.body, headers: response.headers)
  end

  def get_token(repository)
    params = { username: credential.username, password: credential.password }
    url = "https://auth.docker.io/token?service=registry.docker.io&scope=repository:#{repository}:pull"
    response = connection.get(url, params)
    RequestResult.new(result: response.body)
  end

  def authentificated?
    jwt.present?
  end

  private

  def build_connection
    Faraday.new do |conn|
      conn.request(:json)
      conn.response(:json)
      conn.adapter(Faraday.default_adapter)
    end
  end
end

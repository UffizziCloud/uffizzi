# frozen_string_literal: true

class UffizziCore::DockerHubService
  class << self
    def accounts(credential)
      client = user_client(credential)
      response = client.accounts
      Rails.logger.info("DockerHubService accounts response=#{response.inspect} credential_id=#{credential.id}")

      accounts_response = response.result
      accounts_response.nil? ? [] : accounts_response.namespaces
    end

    def user_client(credential)
      return @client if @client&.credential&.username == credential.username

      @client = UffizziCore::DockerHubClient.new(credential)

      unless @client.authentificated?
        Rails.logger.warn("broken credentials, DockerHubService credential_id=#{credential.id}")
        credential.unauthorize! unless credential.unauthorized?
      end

      @client
    end

    def digest(credential, image, tag)
      docker_hub_client = UffizziCore::DockerHubClient.new(credential)
      token = docker_hub_client.get_token(image).result.token
      response = docker_hub_client.digest(image: image, tag: tag, token: token)
      response.headers['docker-content-digest']
    end

    private

    def public_docker_hub_client
      @public_docker_hub_client ||= UffizziCore::DockerHubClient.new
    end
  end
end

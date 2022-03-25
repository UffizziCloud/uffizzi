# frozen_string_literal: true

module UffizziCore::DockerHubService
  HOOK_NAME = "Uffizzi OpenSource Deploy Webhook"
  HOOK_URL = "#{Settings.app.host}api/cli/v1/webhooks/docker_hub"
  REGISTRY = 'registry-1.docker.io'

  class << self
    def create_webhook(credential, image)
      client = user_client(credential)

      webhooks_response = client.get_webhooks(slug: image, registry: REGISTRY)
      Rails.logger.info("DockerHubService create_webhook get_webhooks_response=#{webhooks_response.inspect}")

      return false if webhooks_response.status != 200

      webhooks = webhooks_response.result['results']

      webhook = webhooks.detect { |hook| hook['name'] == HOOK_NAME }

      return true if !webhook.nil?

      params = {
        slug: image,
        name: HOOK_NAME,
        expect_final_callback: false,
        webhooks: [{ name: HOOK_NAME, hook_url: HOOK_URL, registry: REGISTRY }],
      }

      response = client.create_webhook(params)

      Rails.logger.info("DockerHubService create_webhook create_webhook_response=#{response.inspect} params=#{params.inspect}")

      response.status == 201
    end

    def send_webhook_answer(callback_url)
      params = { state: 'success', description: 'Successfully deployed to Uffizzi' }
      public_docker_hub_client.send_webhook_answer(callback_url, params)
    end

    def accounts(credential)
      client = user_client(credential)
      response = client.accounts
      Rails.logger.info("DockerHubService accounts response=#{response.inspect} credential_id=#{credential.id}")

      accounts_response = response.result
      accounts_response.nil? ? [] : accounts_response.namespaces
    end

    def user_client(credential)
      if @client.nil?
        @client = UffizziCore::DockerHubClient.new(credential)

        unless @client.authentificated?
          Rails.logger.warn("broken credentials, DockerHubService credential_id=#{credential.id}")
          credential.unauthorize! unless credential.unauthorized?
        end
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

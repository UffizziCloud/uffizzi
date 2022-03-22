# frozen_string_literal: true

class UffizziCore::Github::AppService
  class << self
    def create_preview_message_into_pull_request(deployment)
      project = deployment.project
      credential = project.credentials.github.last
      return if credential.nil?

      pull_request_payload = deployment.continuous_preview_payload['pull_request']
      installation_id = credential.provider_ref
      message = UffizziCore::Github::MessageService.build_preview_message(deployment)

      create_comment(installation_id, pull_request_payload['repository_full_name'], pull_request_payload['id'], message)
    end

    private

    def create_comment(installation_id, repository, issue_id, message)
      access_token = create_installation_access_token(installation_id)

      installation_client = UffizziCore::Github::InstallationClient.new(access_token)

      installation_client.add_comment(repository, issue_id, message)
    end

    def create_installation_access_token(installation_id)
      access_token_response = app_client.create_app_installation_access_token(installation_id)
      access_token_response[:token]
    end

    def app_client
      UffizziCore::Github::AppClient.new(generate_jwt_token)
    end

    def generate_jwt_token
      rsa_armor = '-----'
      parts = Settings.github.private_key.split(rsa_armor)
      parts[2].gsub!(/\s/, "\n")
      private_key = OpenSSL::PKey::RSA.new(parts.join(rsa_armor))

      payload = {}.tap do |opts|
        opts[:iat] = Time.now.to_i
        opts[:exp] = opts[:iat] + 60
        opts[:iss] = Settings.github.app_id
      end

      JWT.encode(payload, private_key, 'RS256')
    end
  end
end

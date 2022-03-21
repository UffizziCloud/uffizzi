# frozen_string_literal: true

class UffizziCore::Amazon::CredentialService
  class << self
    def credential_correct?(credential)
      access_token(credential).present?
    end

    def access_token(credential)
      response = client(credential).authorization_token
      base64_data = response.authorization_data[0].authorization_token
      token_string = Base64.decode64(base64_data)
      token_items = token_string.split(':')
      token_items.pop
    rescue Aws::ECR::Errors::UnrecognizedClientException, Aws::ECR::Errors::InvalidSignatureException
      ''
    end

    private

    def client(credential)
      region = UffizziCore::AmazonService.get_region_from_registry_url(credential.registry_url)

      UffizziCore::AmazonRegistryClient.new(
        region: region,
        access_key_id: credential.username,
        secret_access_key: credential.password,
      )
    end
  end
end

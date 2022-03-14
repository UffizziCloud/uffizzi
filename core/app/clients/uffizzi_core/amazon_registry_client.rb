# frozen_string_literal: true

class UffizziCore::AmazonRegistryClient
  attr_accessor :client, :token, :registry_url

  def initialize(region:, access_key_id:, secret_access_key:)
    credentials = Aws::Credentials.new(access_key_id, secret_access_key)
    @client = Aws::ECR::Client.new(region: region, credentials: credentials)
  end

  def authorization_token
    client.get_authorization_token({})
  end

  def batch_get_image(image:, tag:)
    client.batch_get_image({ image_ids: [{ image_tag: tag }], repository_name: image })
  end
end

# frozen_string_literal: true

class UffizziCore::AmazonService
  class << self
    def digest(credential, image, tag)
      response = client(credential).batch_get_image(image: image, tag: tag)
      response.images[0].image_id.image_digest
    rescue StandardError
      nil
    end

    def get_region_from_registry_url(url)
      parsed_url = URI.parse(url)
      host = parsed_url.host
      parsed_host = host.split('.')
      parsed_host[3]
    end

    def process_webhook(event, event_data)
      case event
      when 'PUSH'
        source = UffizziCore::Repo::Amazon.name
        image = event_data['repository-name']
        tag = event_data['image-tag']

        UffizziCore::ContinuouslyDeployService.run_docker_registry_process(source, image, tag)
        UffizziCore::ContinuousPreviewService.run_docker_registry_process(source, image, tag)
      else
        Rails.logger.warn("Amazon #{event} event doesn't support")
      end
    end

    private

    def client(credential)
      region = get_region_from_registry_url(credential.registry_url)

      UffizziCore::AmazonRegistryClient.new(
        region: region,
        access_key_id: credential.username,
        secret_access_key: credential.password,
      )
    end
  end
end

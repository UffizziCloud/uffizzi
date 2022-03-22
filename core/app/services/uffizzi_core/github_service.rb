# frozen_string_literal: true

class UffizziCore::GithubService
  class << self
    def send_preview_message(deployment)
      image = deployment.continuous_preview_payload['pull_request']['repository_full_name']
      containers = deployment.containers.where(image: image)
      repo = UffizziCore::Repo.find_by(id: containers.select(:repo_id))

      preview_message_is_enabled = !!repo.share_to_github

      return if !preview_message_is_enabled

      continuous_preview_payload = deployment.continuous_preview_payload
      pull_request_payload = continuous_preview_payload['pull_request']
      new_preview_message = UffizziCore::Github::MessageService.build_preview_message(deployment)

      return if new_preview_message == pull_request_payload['message']

      pull_request_payload['message'] = new_preview_message
      continuous_preview_payload['pull_request'] = pull_request_payload

      deployment.update(continuous_preview_payload: continuous_preview_payload)

      UffizziCore::Github::AppService.create_preview_message_into_pull_request(deployment)
    end
  end
end

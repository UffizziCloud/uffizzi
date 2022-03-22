# frozen_string_literal: true

class UffizziCore::Github::MessageService
  class << self
    def build_preview_message(deployment)
      preview_url = UffizziCore::DeploymentService.build_preview_url(deployment)
      deployment_url = UffizziCore::DeploymentService.build_deployment_url(deployment)

      "**This branch has been deployed using Uffizzi.**

      Preview URL:
      https://#{preview_url}

      View deployment details here:
      https://#{deployment_url}

      This is an automated comment. To turn off commenting, visit uffizzi.com."
    end
  end
end

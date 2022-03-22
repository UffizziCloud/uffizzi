# frozen_string_literal: true

module UffizziCore::TemplateRepo
  extend ActiveSupport::Concern

  included do
    scope :by_docker_containers_with_deploy_preview_when_image_tag_is_created, ->(source, image, tag) {
      general_query = {
        containers_attributes: [
          {
            image: image,
            repo_attributes: {
              type: source,
              deploy_preview_when_image_tag_is_created: true,
            },
          },
        ],
      }

      excluding_query = {
        containers_attributes: [
          {
            image: image,
            tag: tag,
            repo_attributes: {
              type: source,
              deploy_preview_when_image_tag_is_created: true,
            },
          },
        ],
      }

      where('payload @> ?', general_query.to_json).where.not('payload @> ?', excluding_query.to_json)
    }

    scope :by_docker_containers_with_delete_preview_when_image_tag_is_updated, ->(source, image, tag) {
      general_query = {
        containers_attributes: [
          {
            image: image,
            tag: tag,
            repo_attributes: {
              type: source,
              delete_preview_when_image_tag_is_updated: true,
            },
          },
        ],
      }

      where('payload @> ?', general_query.to_json)
    }

    scope :by_github_containers_with_deploy_preview_when_pull_request_is_opened, ->(repository_id, branch) {
      query = {
        containers_attributes: [
          {
            repo_attributes: {
              type: Repo::Github.name,
              repository_id: repository_id,
              branch: branch,
              deploy_preview_when_pull_request_is_opened: true,
            },
          },
        ],
      }

      where('payload @> ?', query.to_json)
    }

    scope :by_github_containers_with_delete_preview_when_pull_request_is_closed, ->(repository_id, branch) {
      query = {
        containers_attributes: [
          {
            repo_attributes: {
              type: Repo::Github.name,
              repository_id: repository_id,
              branch: branch,
              delete_preview_when_pull_request_is_closed: true,
            },
          },
        ],
      }

      where('payload @> ?', query.to_json)
    }
  end
end

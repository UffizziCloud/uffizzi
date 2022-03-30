# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Template::CreateForm < UffizziCore::Template
  include UffizziCore::ApplicationForm

  permit :name,
         payload: {
           containers_attributes: [
             :image,
             :tag,
             :port,
             :public,
             :memory_limit,
             :memory_request,
             :entrypoint,
             :command,
             :receive_incoming_requests,
             :continuously_deploy,
             :name,
             { variables: [:name, :value],
               secret_variables: [:name, :value],
               repo_attributes: [
                 :namespace,
                 :name,
                 :slug,
                 :type,
                 :description,
                 :repository_id,
                 :is_private,
                 :branch,
                 :kind,
                 :dockerfile_path,
                 :dockerfile_context_path,
                 :deploy_preview_when_pull_request_is_opened,
                 :delete_preview_when_pull_request_is_closed,
                 :deploy_preview_when_image_tag_is_created,
                 :delete_preview_when_image_tag_is_updated,
                 :share_to_github,
                 :delete_preview_after,
                 { args: [:name, :value] },
               ],
               container_config_files_attributes: [
                 :config_file_id,
                 :mount_path,
               ] },
           ],
         }

  validate :check_max_memory_limit
  validate :check_max_memory_request

  private

  def check_max_memory_limit
    return if UffizziCore::TemplateService.valid_containers_memory_limit?(self)

    errors.add(:payload, :max_memory_limit_error, max: project.account.container_memory_limit)
  end

  def check_max_memory_request
    return if UffizziCore::TemplateService.valid_containers_memory_request?(self)

    errors.add(:payload, :max_memory_request_error, max: project.account.container_memory_limit)
  end
end

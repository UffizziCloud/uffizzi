# frozen_string_literal: true

class UffizziCore::Repo::QueueBuildJob < UffizziCore::ApplicationJob
  sidekiq_options queue: :deployments, retry: 5

  def perform(repo_id)
    repo = UffizziCore::Repo.find(repo_id)
    UffizziCore::BuildService.create_build!(repo)
  end
end

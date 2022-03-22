# frozen_string_literal: true

class UffizziCore::ComposeFile::Builders::GithubRepoBuilderService
  attr_accessor :repositories

  def initialize(repositories)
    @repositories = repositories
  end

  def build_attributes(build_data)
    repository_data = repository(build_data[:repository_name])

    {
      kind: repository_kind(build_data),
      name: build_data[:repository_name],
      slug: build_data[:repository_name],
      type: UffizziCore::Repo::Github.name,
      branch: branch(build_data, repository_data),
      namespace: build_data[:account_name],
      is_private: nil,
      description: repository_data[:description],
      repository_id: repository_data[:id],
      dockerfile_path: build_data[:dockerfile],
      dockerfile_context_path: build_data[:dockerfile_context_path],
      args: args(build_data),
    }
  end

  private

  def branch(build_data, repository_data)
    build_data[:branch] || repository_data[:default_branch]
  end

  def repository(name)
    repo = repositories.detect { |repository| repository.name.downcase == name.downcase }

    raise UffizziCore::ComposeFile::BuildError, I18n.t('compose.repo_not_found', name: name) if repo.nil?

    repo
  end

  def repository_kind(build_data)
    if build_data[:dockerfile].present?
      UffizziCore::Repo.kind.dockerfile
    else
      UffizziCore::Repo.kind.barestatic
    end
  end

  def args(build_data)
    build_data[:args].map do |arg|
      {
        name: arg[:name],
        value: arg[:value],
      }
    end
  end
end

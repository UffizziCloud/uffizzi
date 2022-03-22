# frozen_string_literal: true

class UffizziCore::Github::UserClient
  PER_PAGE = 100

  def initialize(access_token, per_page = PER_PAGE)
    @client = Octokit::Client.new(access_token: access_token, per_page: per_page)
  end

  def contents?(repository_id, params)
    @client.contents?(repository_id, params)
  end

  def contents(repository_id, options)
    @client.contents(repository_id, options)
  end

  def user_installations
    response = @client.find_user_installations

    response[:installations]
  end

  def installation_repositories(installation_id, repo_attributes)
    response = @client.find_installation_repositories_for_user(installation_id, repo_attributes)

    response[:repositories]
  end

  def branch(repository_id, branch)
    @client.branch(repository_id, branch)
  end

  def commit(repository_id, commit_sha)
    response = @client.commit(repository_id, commit_sha)

    response[:commit]
  end

  def branches(repository_id)
    @client.branches(repository_id)
  end

  def repo(repository_id)
    @client.repo(repository_id)
  end

  def search_repositories(query)
    @client.search_repositories(query)
  end
end

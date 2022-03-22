# frozen_string_literal: true

class UffizziCore::Github::CredentialService
  class << self
    def repository_contains_file?(credential, repository_id, branch, path)
      client(credential).contents?(repository_id, ref: branch, path: path)
    rescue Octokit::Unauthorized
      Rails.logger.warn("broken credentials, repository_contains_file? credential_id=#{credential.id}")
      credential.unauthorize! unless credential.unauthorized?
      raise
    end

    def credential_correct?(credential)
      valid_installation?(credential)
    rescue Octokit::Unauthorized
      false
    end

    def search_repositories(credential, search_query)
      result = client(credential).search_repositories(search_query)

      result[:items]
    rescue Octokit::UnprocessableEntity
      []
    end

    def repositories(credential, query = '', page = 1)
      repo_attributes = {
        sort: :updated,
        page: page,
      }

      repos = client(credential).installation_repositories(credential.provider_ref, repo_attributes)
      filter_repos(repos, query)
    rescue Octokit::Unauthorized
      Rails.logger.warn("broken credentials, repositories credential_id=#{credential.id}")
      credential.unauthorize! unless credential.unauthorized?
      raise
    end

    def branches(credential, repository_id)
      client(credential).branches(repository_id)
    rescue Octokit::Unauthorized
      Rails.logger.warn("broken credentials, branches credential_id=#{credential.id}")
      credential.unauthorize! unless credential.unauthorized?
      raise
    end

    def branch(credential, repository_id, branch)
      client(credential).branch(repository_id, branch)
    rescue Octokit::Unauthorized
      Rails.logger.warn("broken credentials, branch credential_id=#{credential.id}")
      credential.unauthorize! unless credential.unauthorized?
      raise
    end

    def commit(credential, repository_id, commit_sha)
      commit = client(credential).commit(repository_id, commit_sha)

      {
        message: commit[:message],
        committer: commit[:committer][:name],
        commit: commit_sha,
      }
    rescue Octokit::Unauthorized
      Rails.logger.warn("broken credentials, commit credential_id=#{credential.id}")
      credential.unauthorize! unless credential.unauthorized?
      raise
    end

    def contents(credential, repository_id, options)
      client(credential).contents(repository_id, options)
    rescue Octokit::Unauthorized
      Rails.logger.warn("broken credentials, contents credential_id=#{credential.id}")
      credential.unauthorize! unless credential.unauthorized?
      raise
    end

    def repo(credential, repository_id)
      client(credential).repo(repository_id)
    rescue Octokit::Unauthorized
      Rails.logger.warn("broken credentials, repo credential_id=#{credential.id}")
      credential.unauthorize! unless credential.unauthorized?
      raise
    end

    def repo_url(credential, repository_id)
      repo = repo(credential, repository_id)
      repo[:clone_url].split(%r{https://}).last
    end

    def file_content(credential, repository_id, branch, file_path)
      file = contents(credential, repository_id, ref: branch, path: file_path)
      Base64.decode64(file[:content])
    rescue Octokit::Unauthorized
      Rails.logger.warn("broken credentials, file_content credential_id=#{credential.id}")
      credential.unauthorize! unless credential.unauthorized?
      raise
    end

    private

    def client(credential)
      UffizziCore::Github::UserClient.new(credential.password)
    end

    def valid_installation?(credential)
      user_installations = client(credential).user_installations

      installation = user_installations.detect do |user_installation|
        user_installation[:id].to_s == credential.provider_ref
      end

      installation.present?
    end

    def filter_repos(repos, query)
      return repos if query.blank?

      prepared_query = query.downcase
      repos.select { |repo| repo.full_name.downcase.include?(prepared_query) || repo.description&.downcase&.include?(prepared_query) }
    end
  end
end

# frozen_string_literal: true

module UffizziCore::GithubStubSupport
  API_URL = 'https://api.github.com'

  def stub_github_branch_request(repository_id, branch, data, status = 200)
    uri = "#{API_URL}/repositories/#{repository_id}/branches/#{branch}"

    stub_request(:get, uri).to_return(status: status, body: data.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def stub_github_commit_request(repo, commit_sha, data)
    uri = "#{API_URL}/repositories/#{repo.repository_id}/commits/#{commit_sha}"

    stub_request(:get, uri).to_return(status: 200, body: data.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def stub_repository_request(repository_id, data)
    uri = "#{API_URL}/repositories/#{repository_id}"

    stub_request(:get, uri).to_return(status: 200, body: data.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def stub_github_create_app_installation_access_token_request(installation_id, data)
    uri = "#{API_URL}/app/installations/#{installation_id}/access_tokens"

    stub_request(:post, uri).to_return(status: 200, body: data.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def stub_github_add_issue(full_repository_name, issue_id, data)
    uri = "#{API_URL}/repos/#{full_repository_name}/issues/#{issue_id}/comments"

    stub_request(:post, uri).to_return(status: 200, body: data.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def stub_github_contains_request(repository_id, branch, path, status = 200)
    uri = "#{API_URL}/repositories/#{repository_id}/contents/#{path}?ref=#{branch}"

    stub_request(:head, uri).to_return(status: status, body: '', headers: { 'Content-Type' => 'application/json' })
  end

  def stub_github_content_request(repository_id, branch, path, data)
    uri = "#{API_URL}/repositories/#{repository_id}/contents/#{path}?ref=#{branch}"

    stub_request(:get, uri).to_return(status: 200, body: data.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def stub_github_content_not_found_request(repository_id, branch, path)
    uri = "#{API_URL}/repositories/#{repository_id}/contents/#{path}?ref=#{branch}"

    stub_request(:get, uri).to_return(status: 404, headers: { 'Content-Type' => 'application/json' })
  end

  def stub_github_repositories_request(installation_id, data)
    uri = "#{API_URL}/user/installations/#{installation_id}/repositories?page=1&per_page=#{Github::UserClient::PER_PAGE}&sort=updated"

    stub_request(:get, uri).to_return(status: 200, body: data.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def stub_github_user_installations(data, code = 200)
    uri = "#{API_URL}/user/installations?per_page=100"

    stub_request(:get, uri).to_return(status: code, body: data.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def stub_github_search_repositories_request(data)
    uri = %r{#{API_URL}/search/repositories}

    stub_request(:get, uri).to_return(status: 200, body: data.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def stub_github_installation_request(installation_id, data)
    uri = "#{API_URL}/app/installations/#{installation_id}"

    stub_request(:get, uri).to_return(status: 200, body: data.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def stub_github_user_installations_request(data)
    uri = %r{#{API_URL}/user/installations}

    stub_request(:get, uri).to_return(status: 200, body: data.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def stub_github_pull_request_files_request(repository_id, request_number, data, page)
    uri = "#{API_URL}/repositories/#{repository_id}/pulls/#{request_number}/files?page=#{page}&per_page=100"

    stub_request(:get, uri).to_return(status: 200, body: data.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def stub_github_delete_app_authorization_request(_access_token, client_id)
    uri = "#{API_URL}/applications/#{client_id}/grant"

    stub_request(:delete, uri).to_return(status: 204)
  end

  def stub_github_delete_installation_request(installation_id)
    uri = "#{API_URL}/app/installations/#{installation_id}"

    stub_request(:delete, uri).to_return(status: 204, headers: { 'Content-Type' => 'application/json' })
  end
end

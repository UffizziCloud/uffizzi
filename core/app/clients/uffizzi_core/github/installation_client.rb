# frozen_string_literal: true

class UffizziCore::Github::InstallationClient
  def initialize(access_token)
    @client = Octokit::Client.new(access_token: access_token)
  end

  def add_comment(repository, issue_id, message)
    @client.add_comment(repository, issue_id, message)
  end
end

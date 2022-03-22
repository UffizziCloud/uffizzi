# frozen_string_literal: true

class UffizziCore::Github::AppClient
  def initialize(jwt_token)
    @client = Octokit::Client.new(bearer_token: jwt_token)
  end

  def delete_installation(installation_id)
    @client.delete_installation(installation_id)
  end

  def create_app_installation_access_token(installation_id)
    @client.create_app_installation_access_token(installation_id)
  end

  def installation(installation_id)
    @client.installation(installation_id)
  end
end

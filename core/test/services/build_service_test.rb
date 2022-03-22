# frozen_string_literal: true

require 'test_helper'

class UffizziCore::BuildServiceTest < ActiveSupport::TestCase
  setup do
    @user = create(:user, :with_organizational_account)
    @account = @user.organizational_account
    @credential = create(:credential, :github, account: @account, provider_ref: generate(:number))
    @project = create(:project, account: @account)
    @deployment = create(:deployment, project: @project)

    google_build_stub
  end

  test '#create_cloud_build - check image arguments build' do
    repository_data = json_fixture('files/github/repository.json')
    stub_github_repository_request = stub_repository_request(repository_data[:id], repository_data)

    repo = create(
      :repo,
      :github,
      :kind_dockerfile,
      project: @project,
      repository_id: repository_data[:id],
      dockerfile_path: 'Dockerfile',
      args: [{ name: generate(:string), value: generate(:number) }],
    )

    create(:container, deployment: @deployment, repo: repo)
    build = create(:build, repo: repo)

    UffizziCore::BuildService.create_cloud_build(build)

    assert_requested(stub_github_repository_request)
  end
end

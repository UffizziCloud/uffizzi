# frozen_string_literal: true

require 'test_helper'

class UffizziCore::GithubServiceTest < ActiveSupport::TestCase
  test '#send_preview_message - sent successfully' do
    user = create(:user, :with_organizational_account)
    account = user.organizational_account
    credential = create(:credential, :github, :active, account: account, username: 'github_user', provider_ref: 'installation_id')
    project = create(:project, :with_members, account: account, members: [user])

    repository_id = 357_590_782
    image = 'github_user/hello-world'
    image_namespace, image_name = image.split('/')
    source_branch = 'testing'
    target_branch = 'master'
    repo_attributes = attributes_for(
      :repo,
      :github,
      :kind_buildpacks18,
      repository_id: repository_id,
      namespace: image_namespace,
      name: image_name,
      branch: target_branch,
      deploy_preview_when_pull_request_is_opened: true,
      delete_preview_when_pull_request_is_closed: true,
      share_to_github: true,
    )
    container_attributes = attributes_for(
      :container,
      :with_public_port,
      image: image,
      tag: target_branch,
      receive_incoming_requests: true,
      repo_attributes: repo_attributes,
    )
    template_payload = {
      containers_attributes: [container_attributes],
    }

    template = create(:template, project: project, added_by: user, payload: template_payload)

    containers_attributes = template[:payload]['containers_attributes'].map do |item|
      item['repo_attributes']['project_id'] = project.id
      item['continuously_deploy'] = UffizziCore::Container::STATE_ENABLED

      if item['image'] == image
        item['repo_attributes']['branch'] = source_branch
        item['tag'] = source_branch
      end

      item
    end

    continuous_preview_payload = { pull_request: { id: 1, message: '', repository_full_name: image } }

    deployment = UffizziCore::Deployment.create!(
      project: project,
      deployed_by: user,
      creation_source: UffizziCore::Deployment.creation_source.continuous_preview,
      subdomain: 'subdomain',
      containers_attributes: containers_attributes,
      continuous_preview_payload: continuous_preview_payload,
    )

    stubbed_github_create_app_installation_access_token_request = stub_github_create_app_installation_access_token_request(
      credential.provider_ref, { token: 'some_token' }
    )
    stubed_github_add_issue = stub_github_add_issue(deployment.continuous_preview_payload['pull_request']['repository_full_name'],
                                                    deployment.continuous_preview_payload['pull_request']['id'], {})

    UffizziCore::GithubService.send_preview_message(deployment)

    assert_requested stubbed_github_create_app_installation_access_token_request
    assert_requested stubed_github_add_issue
  end

  test '#send_preview_message - preview message is disabled' do
    user = create(:user, :with_organizational_account)
    account = user.organizational_account
    credential = create(:credential, :github, :active, account: account, username: 'github_user', provider_ref: 'installation_id')
    project = create(:project, :with_members, account: account, members: [user])

    repository_id = 357_590_782
    image = 'github_user/hello-world'
    image_namespace, image_name = image.split('/')
    source_branch = 'testing'
    target_branch = 'master'
    repo_attributes = attributes_for(
      :repo,
      :github,
      :kind_buildpacks18,
      repository_id: repository_id,
      namespace: image_namespace,
      name: image_name,
      branch: target_branch,
      deploy_preview_when_pull_request_is_opened: true,
      delete_preview_when_pull_request_is_closed: true,
      share_to_github: false,
    )
    container_attributes = attributes_for(
      :container,
      :with_public_port,
      image: image,
      tag: target_branch,
      receive_incoming_requests: true,
      repo_attributes: repo_attributes,
    )
    template_payload = {
      containers_attributes: [container_attributes],
    }

    template = create(:template, project: project, added_by: user, payload: template_payload)

    containers_attributes = template[:payload]['containers_attributes'].map do |item|
      item['repo_attributes']['project_id'] = project.id
      item['continuously_deploy'] = UffizziCore::Container::STATE_ENABLED

      if item['image'] == image
        item['repo_attributes']['branch'] = source_branch
        item['tag'] = source_branch
      end

      item
    end

    continuous_preview_payload = { pull_request: { id: 1, message: '', repository_full_name: image } }

    deployment = UffizziCore::Deployment.create!(
      project: project,
      deployed_by: user,
      creation_source: UffizziCore::Deployment.creation_source.continuous_preview,
      subdomain: 'subdomain',
      containers_attributes: containers_attributes,
      continuous_preview_payload: continuous_preview_payload,
    )

    stubbed_github_create_app_installation_access_token_request = stub_github_create_app_installation_access_token_request(
      credential.provider_ref, { token: 'some_token' }
    )
    stubed_github_add_issue = stub_github_add_issue(deployment.continuous_preview_payload['pull_request']['repository_full_name'],
                                                    deployment.continuous_preview_payload['pull_request']['id'], {})

    UffizziCore::GithubService.send_preview_message(deployment)

    assert_not_requested stubbed_github_create_app_installation_access_token_request
    assert_not_requested stubed_github_add_issue
  end

  test '#send_preview_message - duplicate message was not sent' do
    user = create(:user, :with_organizational_account)
    account = user.organizational_account
    credential = create(:credential, :github, :active, account: account, username: 'github_user', provider_ref: 'installation_id')
    project = create(:project, :with_members, account: account, members: [user])

    repository_id = 357_590_782
    image = 'github_user/hello-world'
    image_namespace, image_name = image.split('/')
    source_branch = 'testing'
    target_branch = 'master'
    repo_attributes = attributes_for(
      :repo,
      :github,
      :kind_buildpacks18,
      repository_id: repository_id,
      namespace: image_namespace,
      name: image_name,
      branch: target_branch,
      deploy_preview_when_pull_request_is_opened: true,
      delete_preview_when_pull_request_is_closed: true,
    )
    container_attributes = attributes_for(
      :container,
      :with_public_port,
      image: image,
      tag: target_branch,
      receive_incoming_requests: true,
      repo_attributes: repo_attributes,
    )
    template_payload = {
      containers_attributes: [container_attributes],
    }

    template = create(:template, project: project, added_by: user, payload: template_payload)

    containers_attributes = template[:payload]['containers_attributes'].map do |item|
      item['repo_attributes']['project_id'] = project.id
      item['continuously_deploy'] = UffizziCore::Container::STATE_ENABLED

      if item['image'] == image
        item['repo_attributes']['branch'] = source_branch
        item['tag'] = source_branch
      end

      item
    end

    deployment = UffizziCore::Deployment.create!(
      project: project,
      deployed_by: user,
      creation_source: UffizziCore::Deployment.creation_source.continuous_preview,
      subdomain: 'subdomain',
      containers_attributes: containers_attributes,
    )

    continuous_preview_payload = { pull_request: { id: 1, message: UffizziCore::Github::MessageService.build_preview_message(deployment),
                                                   repository_full_name: image } }

    deployment.update(continuous_preview_payload: continuous_preview_payload)

    stubbed_github_create_app_installation_access_token_request = stub_github_create_app_installation_access_token_request(
      credential.provider_ref, { token: 'some_token' }
    )
    stubed_github_add_issue = stub_github_add_issue(deployment.continuous_preview_payload['pull_request']['repository_full_name'],
                                                    deployment.continuous_preview_payload['pull_request']['id'], {})

    UffizziCore::GithubService.send_preview_message(deployment)

    assert_not_requested stubbed_github_create_app_installation_access_token_request
    assert_not_requested stubed_github_add_issue
  end
end

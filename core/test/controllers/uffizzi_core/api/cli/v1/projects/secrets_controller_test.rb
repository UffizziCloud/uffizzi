# frozen_string_literal: true

require 'test_helper'

class UffizziCore::Api::Cli::V1::Projects::SecretsControllerTest < ActionController::TestCase
  setup do
    @admin = create(:user, :with_organizational_account)
    @account = @admin.organizational_account
    @developer = create(:user, :developer_in_organization, organization: @account)
    @viewer = create(:user, :viewer_in_organization, organization: @account)
    secrets = [build(:secret, name: generate(:string), value: generate(:string))]
    @project = create(:project, :with_members, account: @account, members: [@admin, @developer, @viewer], secrets: secrets)

    sign_in @admin
  end

  test '#index admin gets list of secrets' do
    params = {
      project_slug: @project.slug,
    }

    get :index, params: params, format: :json

    assert_response :success
  end

  test '#bulk_create admin creates secrets' do
    new_secrets = [
      { name: generate(:string), value: generate(:string) },
      { name: generate(:string), value: generate(:string) },
    ]

    params = {
      project_slug: @project.slug,
      secrets: new_secrets,
    }

    differences = {
      -> { UffizziCore::Project.find(@project.id).secrets.count } => new_secrets.count,
    }

    assert_difference differences do
      post :bulk_create, params: params, format: :json
    end

    assert_response :success
  end

  test '#bulk_create check if a secret has already been added' do
    new_secrets = [
      { name: @project.secrets.first['name'], value: generate(:string) },
    ]

    params = {
      project_slug: @project.slug,
      secrets: new_secrets,
    }

    post :bulk_create, params: params, format: :json
    assert_response :unprocessable_entity

    response_body = JSON.parse(response.body)
    assert { response_body['errors']['secrets'].present? }
  end

  test '#bulk_create check update secret in a compose' do
    new_secrets = [
      { name: generate(:string), value: generate(:string) },
    ]

    compose_file = create(:compose_file, project: @project, added_by: @admin)

    container_attributes = attributes_for(
      :container,
      :with_public_port,
      receive_incoming_requests: true,
      secret_variables: [{ name: new_secrets.first[:name], value: '' }],
    )
    template_payload = { containers_attributes: [container_attributes] }
    create(:template, :compose_file_source, compose_file: compose_file, project: @project, added_by: @admin, payload: template_payload)

    params = {
      project_slug: @project.slug,
      secrets: new_secrets,
    }

    post :bulk_create, params: params, format: :json
    assert_response :success

    compose_file.reload
    @project.reload

    new_project_secret = @project.secrets.detect { |project_secret| project_secret['name'] == new_secrets.first[:name] }
    container = compose_file.template.payload['containers_attributes'].first
    compose_secret = container['secret_variables'].detect { |container_secret| container_secret['name'] == new_secrets.first[:name] }

    assert_equal(new_project_secret['value'], compose_secret['value'])
  end

  test '#bulk_create check update secret in a compose if it has invalid secrets' do
    new_secrets = [
      { name: generate(:string), value: generate(:string) },
    ]

    compose_additional_secrets = [
      { name: generate(:string), value: generate(:string) },
    ]

    compose_payload = { errors: { secret_variables: [generate(:string)] } }
    compose_file = create(:compose_file, :invalid_file, project: @project, added_by: @admin, payload: compose_payload)

    container_attributes = attributes_for(
      :container,
      :with_public_port,
      receive_incoming_requests: true,
      secret_variables: [{ name: new_secrets.first[:name], value: '' }] + compose_additional_secrets,
    )
    template_payload = { containers_attributes: [container_attributes] }
    create(:template, :compose_file_source, compose_file: compose_file, project: @project, added_by: @admin, payload: template_payload)

    params = {
      project_slug: @project.slug,
      secrets: new_secrets,
    }

    post :bulk_create, params: params, format: :json
    assert_response :success

    compose_file.reload
    @project.reload

    new_project_secret = @project.secrets.detect { |project_secret| project_secret['name'] == new_secrets.first[:name] }
    container = compose_file.template.payload['containers_attributes'].first
    compose_secret = container['secret_variables'].detect { |container_secret| container_secret['name'] == new_secrets.first[:name] }

    assert_equal(new_project_secret['value'], compose_secret['value'])
    assert(compose_file.invalid_file?)
    refute_empty(compose_file.payload['errors'])
  end

  test '#bulk_create check update secret in a compose if it has errors with secrets' do
    @project.secrets.destroy_all

    new_secrets = [
      { name: generate(:string), value: generate(:string) },
    ]

    compose_payload = { errors: { secret_variables: [generate(:string)] } }
    compose_file = create(:compose_file, :invalid_file, project: @project, added_by: @admin, payload: compose_payload)

    container_attributes = attributes_for(
      :container,
      :with_public_port,
      receive_incoming_requests: true,
      secret_variables: [{ name: new_secrets.first[:name], value: '' }],
    )
    template_payload = { containers_attributes: [container_attributes] }
    create(:template, :compose_file_source, compose_file: compose_file, project: @project, added_by: @admin, payload: template_payload)

    params = {
      project_slug: @project.slug,
      secrets: new_secrets,
    }

    post :bulk_create, params: params, format: :json
    assert_response :success

    compose_file.reload
    @project.reload

    new_project_secret = @project.secrets.detect { |project_secret| project_secret['name'] == new_secrets.first[:name] }
    container = compose_file.template.payload['containers_attributes'].first
    compose_secret = container['secret_variables'].detect { |container_secret| container_secret['name'] == new_secrets.first[:name] }

    assert { compose_file.valid_file? }
    assert_equal(new_project_secret['value'], compose_secret['value'])
    assert_empty(compose_file.payload['errors'])
  end

  test '#bulk_create check update secret in a compose if it has errors not related to secrets' do
    @project.secrets.destroy_all

    new_secrets = [
      { name: generate(:string), value: generate(:string) },
    ]

    compose_payload = { errors: { secret_variables: [generate(:string)], error_key: [generate(:string)] } }
    compose_file = create(:compose_file, :invalid_file, project: @project, added_by: @admin, payload: compose_payload)

    container_attributes = attributes_for(
      :container,
      :with_public_port,
      receive_incoming_requests: true,
      secret_variables: [{ name: new_secrets.first[:name], value: '' }],
    )
    template_payload = { containers_attributes: [container_attributes] }
    create(:template, :compose_file_source, compose_file: compose_file, project: @project, added_by: @admin, payload: template_payload)

    params = {
      project_slug: @project.slug,
      secrets: new_secrets,
    }

    post :bulk_create, params: params, format: :json
    assert_response :success

    compose_file.reload
    @project.reload

    new_project_secret = @project.secrets.detect { |project_secret| project_secret['name'] == new_secrets.first[:name] }
    container = compose_file.template.payload['containers_attributes'].first
    compose_secret = container['secret_variables'].detect { |container_secret| container_secret['name'] == new_secrets.first[:name] }

    assert { compose_file.invalid_file? }
    assert_equal(new_project_secret['value'], compose_secret['value'])
    refute_empty(compose_file.payload['errors'])
  end

  test '#destroy admin deletes a secret' do
    deletable_secret = UffizziCore::Project.find(@project.id).secrets.last

    params = {
      project_slug: @project.slug,
      id: deletable_secret['name'],
    }

    differences = {
      -> { UffizziCore::Project.last.secrets.count } => -1,
    }

    assert_difference differences do
      delete :destroy, params: params, format: :json
    end

    assert_response :success
  end

  test '#destroy if a project has a compose with deleted secret' do
    deletable_secret = UffizziCore::Project.find(@project.id).secrets.last
    compose_file = create(:compose_file, project: @project, added_by: @admin)

    container_attributes = attributes_for(
      :container,
      :with_public_port,
      receive_incoming_requests: true,
      secret_variables: [deletable_secret],
    )
    template_payload = { containers_attributes: [container_attributes] }
    create(:template, :compose_file_source, compose_file: compose_file, project: @project, added_by: @admin, payload: template_payload)

    params = {
      project_slug: @project.slug,
      id: deletable_secret['name'],
    }

    differences = {
      -> { UffizziCore::Project.last.secrets.count } => -1,
      -> { UffizziCore::ComposeFile.where(state: UffizziCore::ComposeFile::STATE_INVALID_FILE).count } => 1,
    }

    assert_difference differences do
      delete :destroy, params: params, format: :json
    end

    assert_response :success

    compose_file.reload

    assert { compose_file.invalid_file? }
    refute_empty(compose_file.payload['errors'])
  end

  test '#destroy if a secret doesn\'t exist' do
    params = {
      project_slug: @project.slug,
      id: generate(:string),
    }

    differences = {
      -> { UffizziCore::Project.last.secrets.count } => 0,
    }

    assert_difference differences do
      delete :destroy, params: params, format: :json
    end

    assert_response :not_found
  end
end

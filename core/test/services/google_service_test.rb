# frozen_string_literal: true

require 'test_helper'

class UffizziCore::GoogleServiceTest < ActiveSupport::TestCase
  test '#digest' do
    image = generate(:image)
    tag = generate(:tag)
    user = create(:user, :with_personal_account)
    credential = create(:credential, :google, :active, account: user.personal_account)

    headers_response = { 'docker-content-digest': generate(:string) }
    token_response = { token: generate(:string) }

    stubbed_google_registry_token = stub_google_registry_token(token_response)
    stubbed_google_registry_manifests = stub_google_registry_manifests(image, tag, headers_response, {})

    digest = UffizziCore::ContainerRegistry::GoogleService.digest(credential, image, tag)

    assert_requested stubbed_google_registry_token
    assert_requested stubbed_google_registry_manifests
    assert digest.present?
  end
end

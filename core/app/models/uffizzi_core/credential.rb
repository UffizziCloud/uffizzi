# frozen_string_literal: true

class UffizziCore::Credential < UffizziCore::ApplicationRecord
  include UffizziCore::Concerns::Models::Credential
  extend Enumerize

  enumerize :type,
            in: [
              UffizziCore::Credential::GithubContainerRegistry.name,
              UffizziCore::Credential::DockerHub.name,
              UffizziCore::Credential::DockerRegistry.name,
              UffizziCore::Credential::Azure.name,
              UffizziCore::Credential::Google.name,
              UffizziCore::Credential::Amazon.name,
            ], i18n_scope: ['enumerize.credential.type']
end

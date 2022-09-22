# frozen_string_literal: true

class UffizziCore::Credential < UffizziCore::ApplicationRecord
  include UffizziCore::Concerns::Models::Credential
  extend Enumerize

  enumerize :type,
            in: [
              UffizziCore::Credential::Amazon.name,
              UffizziCore::Credential::Azure.name,
              UffizziCore::Credential::DockerHub.name,
              UffizziCore::Credential::DockerRegistry.name,
              UffizziCore::Credential::GithubContainerRegistry.name,
              UffizziCore::Credential::Google.name,
            ], i18n_scope: ['enumerize.credential.type']
end

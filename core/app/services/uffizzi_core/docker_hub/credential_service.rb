# frozen_string_literal: true

class UffizziCore::DockerHub::CredentialService
  class << self
    def credential_correct?(credential)
      client(credential).authentificated?
    end

    private

    def client(credential)
      UffizziCore::DockerHubClient.new(credential)
    end
  end
end

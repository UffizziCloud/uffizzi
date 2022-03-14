# frozen_string_literal: true

module UffizziCore::ComposeFileRepo
  extend ActiveSupport::Concern

  included do
    scope :with_auto_deploy, -> {
      where(auto_deploy: UffizziCore::ComposeFile::STATE_ENABLED)
    }
  end
end

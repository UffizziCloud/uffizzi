# frozen_string_literal: true

module UffizziCore::BuildRepo
  extend ActiveSupport::Concern

  included do
    scope :successful, -> {
      where(status: UffizziCore::Build::SUCCESS)
    }

    scope :building, -> {
      where(status: UffizziCore::Build::BUILDING)
    }

    scope :queued, -> {
      where(status: [nil])
    }

    scope :deployed, -> {
      where(deployed: true)
    }
  end
end

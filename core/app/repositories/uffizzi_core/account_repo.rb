# frozen_string_literal: true

module UffizziCore::AccountRepo
  extend ActiveSupport::Concern

  included do
    scope :by_kind, ->(kind) { where(kind: kind) }
    scope :personal, -> { by_kind(UffizziCore::Account.kind.personal) }
    scope :organizational, -> { by_kind(UffizziCore::Account.kind.organizational) }
  end
end

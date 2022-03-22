# frozen_string_literal: true

module UffizziCore::ProjectRepo
  extend ActiveSupport::Concern

  included do
    scope :by_ids, ->(ids) { where(id: ids) }
    scope :by_accounts, ->(account_ids) { where(account_id: account_ids) }
  end
end

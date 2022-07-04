# frozen_string_literal: true

module UffizziCore::UserRepo
  extend ActiveSupport::Concern

  included do
    scope :by_email, ->(email) {
      where('lower(email) = ?', email.downcase)
    }
    scope :with_single_account, -> {
      joins(:memberships).group('users.id').having('count(memberships.id) = 1')
    }
    scope :with_account, ->(account_id) {
      joins(:memberships).where(memberships: { account_id: account_id })
    }
  end
end

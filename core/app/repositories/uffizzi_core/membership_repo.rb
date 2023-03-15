# frozen_string_literal: true

module UffizziCore::MembershipRepo
  extend ActiveSupport::Concern

  included do
    scope :by_role_admin, -> { by_role(UffizziCore::Membership.role.admin) }
    scope :by_account, ->(account) { where(account_id: account.id) }
  end
end

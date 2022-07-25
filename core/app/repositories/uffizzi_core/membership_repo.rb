# frozen_string_literal: true

module UffizziCore::MembershipRepo
  extend ActiveSupport::Concern

  included do
    scope :by_role_admin, -> { by_role(UffizziCore::Membership.role.admin) }
  end
end

# frozen_string_literal: true

class UffizziCore::Migrations::AccountService
  class << self
    def remove_draft_accounts
      UffizziCore::Account.where(state: 'draft').find_each(&:destroy)
    end
  end
end

# frozen_string_literal: true

class UffizziCore::Migrations::AccountService
  class << self
    def remove_draft_accounts
      UffizziCore::Account.where(state: 'draft').find_each do |account|
        account.owner.destroy
        account.destroy
      end
    end
  end
end

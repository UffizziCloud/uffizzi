# frozen_string_literal: true

namespace :migration do
  desc 'destroy all draft accounts'
  task migrate_draft_accounts: :environment do
    UffizziCore::Migrations::AccountService.remove_draft_accounts
    puts 'Success'
  end
end

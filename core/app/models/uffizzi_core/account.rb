# frozen_string_literal: true

class UffizziCore::Account < UffizziCore::ApplicationRecord
  include UffizziCore::Concerns::Models::Account

  belongs_to :owner, class_name: UffizziCore::User.name, foreign_key: :owner_id
end

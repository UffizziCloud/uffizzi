# frozen_string_literal: true

module UffizziCore::UserRepo
  extend ActiveSupport::Concern

  included do
    scope :by_email, ->(email) {
      where('lower(email) = ?', email.downcase)
    }
  end
end

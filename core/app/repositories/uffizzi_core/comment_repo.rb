# frozen_string_literal: true

module UffizziCore::CommentRepo
  extend ActiveSupport::Concern

  included do
    scope :by_user, ->(user) {
      where(user: user)
    }
  end
end

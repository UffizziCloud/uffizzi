# frozen_string_literal: true

class UffizziCore::User < ActiveRecord::Base
  include UffizziCore::Concerns::Models::User

  has_secure_password

  validates :email, presence: true, 'uffizzi_core/email': true, uniqueness: { case_sensitive: false }
  validates :password, allow_nil: true, length: { minimum: 8 }, on: :update
end

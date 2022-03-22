# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::SessionCreateForm
  include UffizziCore::ApplicationFormWithoutActiveRecord

  attribute :email, String
  attribute :password, String

  validates :email, :password, presence: true
  validate :check_authenticate, if: :email

  def user
    @user ||= UffizziCore::User.active.by_email(email).first
  end

  def check_authenticate
    return unless wrong_email_or_password?

    errors.add(:password, 'Email or password is incorrect.')
  end

  private

  def wrong_email_or_password?
    return true if user.nil?

    !user.authenticate(password)
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :payment, class: UffizziCore::Payment do
    account { nil }
  end
end

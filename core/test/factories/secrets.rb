# frozen_string_literal: true

FactoryBot.define do
  factory :secret, class: UffizziCore::Secret do
    resource { nil }
    name { nil }
    value { nil }
  end
end

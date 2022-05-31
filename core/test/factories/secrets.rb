# frozen_string_literal: true

FactoryBot.define do
  factory :secret, class: UffizziCore::Secret do
    resource { nil }
    name { generate(:string) }
    value { generate(:string) }
  end
end

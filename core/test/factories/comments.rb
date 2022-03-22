# frozen_string_literal: true

FactoryBot.define do
  factory :comment, class: UffizziCore::Comment do
    commentable { nil }
    content
    parent { nil }
    user { nil }
  end
end

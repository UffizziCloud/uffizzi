# frozen_string_literal: true

FactoryBot.define do
  factory :project_secret, class: 'UffizziCore::Project::Secret' do
    project { nil }
    name { nil }
    value { nil }
  end
end

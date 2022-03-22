# frozen_string_literal: true

FactoryBot.define do
  sequence :time do
    Faker::Time.between(from: DateTime.now - 1, to: DateTime.now)
  end

  sequence :string,
           aliases: [
             :tag, :namespace, :branch, :phone, :website, :twitter, :github,
             :linkedin, :devto, :facebook, :blog, :bio, :status, :availability,
             :primary_skills, :learning, :coding_for, :education, :title, :work,
             :primary_location, :content, :login
           ] do |n|
    "string_#{n}"
  end

  sequence :image do |n|
    "namespace/name-#{n}"
  end

  sequence :kubernetes_name do |n|
    "kubernetes-name-#{n}"
  end

  sequence :commit do |n|
    "commit-hash-#{n}"
  end

  sequence :commit_message do |n|
    "commit-message-#{n}"
  end

  sequence :slug do |n|
    "slug_#{n}"
  end

  sequence :name, aliases: [:first_name, :last_name, :username, :description] do |n|
    "Name #{n}"
  end

  sequence :token, aliases: [:confirmation_token, :customer_token, :subscription_token] do |_n|
    UffizziCore::TokenService.generate
  end

  sequence :url, aliases: [:image_url] do |n|
    "http://url#{n}.com"
  end

  sequence :password do |n|
    "Password1String-#{n}"
  end

  sequence :email do |n|
    "user#{n}@example.com"
  end

  sequence :instance_name do |n|
    "project-name-#{Time.now.to_i}-#{n}"
  end

  sequence :path do |n|
    "/volumes/directory-#{n}"
  end

  sequence :number, aliases: [
    :integer,
    :mileage,
    :ram,
    :port,
    :selected_storage_size,
    :storage_initial,
    :storage_capacity,
    :max_connections,
    :base_price_per_month,
    :extra_gigabyte_price_per_hour,
    :memory_limit,
    :claps,
  ] do |n|
    n
  end

  sequence :boolean, aliases: [
    :has_public_ip,
    :has_storage_autoscaling,
    :has_high_availability,
    :backups_mandatory,
    :has_shared_memory,
  ] do
    Faker::Boolean.boolean
  end

  sequence :vcpu do |n|
    ['shared', n].sample
  end

  sequence :domain_name, aliases: [:domain] do
    Faker::Internet.domain_name(subdomain: true)
  end

  sequence :subdomain_name do |_n|
    Faker::Lorem
      .words(number: 2, supplemental: true)
      .join('-')
      .delete(',. ')
      .downcase
  end

  sequence :created_at, aliases: ['updated_at'] do
    DateTime.now
  end
end

# frozen_string_literal: true

module UffizziCore::ActivityItemRepo
  extend ActiveSupport::Concern

  included do
    include UffizziCore::BasicOrderRepo
  end
end

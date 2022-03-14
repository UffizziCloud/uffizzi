# frozen_string_literal: true

module UffizziCore::EventRepo
  extend ActiveSupport::Concern

  included do
    include UffizziCore::BasicOrderRepo
  end
end

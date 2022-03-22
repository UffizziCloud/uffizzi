# frozen_string_literal: true

class UffizziCore::Event < UffizziCore::ApplicationRecord
  include UffizziCore::EventRepo
  extend Enumerize

  self.table_name = Rails.application.config.uffizzi_core[:table_names][:events]

  enumerize :state, in: [:queued, :successful, :deployed, :failed, :building, :timeout, :cancelled, :deploying], predicates: true,
                    scope: true

  belongs_to :activity_item, touch: true
end

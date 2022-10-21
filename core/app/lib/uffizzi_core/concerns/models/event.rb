# frozen_string_literal: true

module UffizziCore::Concerns::Models::Event
  extend ActiveSupport::Concern

  included do
    include UffizziCore::EventRepo
    extend Enumerize

    self.table_name = UffizziCore.table_names[:events]

    enumerize :state, in: [:waiting, :queued, :successful, :deployed, :failed, :building, :timeout, :cancelled, :deploying],
                      predicates: true, scope: true

    belongs_to :activity_item, touch: true
  end
end

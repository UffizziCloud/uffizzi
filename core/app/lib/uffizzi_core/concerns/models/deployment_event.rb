# frozen_string_literal: true

module UffizziCore::Concerns::Models::DeploymentEvent
  extend ActiveSupport::Concern

  included do
    self.table_name = UffizziCore.table_names[:deployment_events]

    belongs_to :deployment
  end
end

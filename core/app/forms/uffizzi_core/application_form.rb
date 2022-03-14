# frozen_string_literal: true

module UffizziCore::ApplicationForm
  extend ActiveSupport::Concern

  include UffizziCore::MassAssignmentControlConcern

  class_methods do
    delegate :model_name, :name, to: :superclass
  end
end

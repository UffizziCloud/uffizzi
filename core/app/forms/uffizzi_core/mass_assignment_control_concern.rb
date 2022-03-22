# frozen_string_literal: true

module UffizziCore::MassAssignmentControlConcern
  extend ActiveSupport::Concern

  class_methods do
    def permit(*args)
      @_args = args
    end

    def _args
      @_args
    end
  end

  def assign_attributes(attrs = ActionController::Parameters.new)
    attrs = ActionController::Parameters.new if attrs.nil?

    new_attrs = attrs.permit(*self.class._args)
    super(new_attrs)
  end
end

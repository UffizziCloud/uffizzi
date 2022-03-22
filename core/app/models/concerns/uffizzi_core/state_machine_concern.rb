# frozen_string_literal: true

module UffizziCore::StateMachineConcern
  extend ActiveSupport::Concern

  class_methods do
    def aasm(attribute, *args)
      attr_accessor(:"#{attribute}_event")

      define_method("#{attribute}_event=") do |value|
        send(value)
      end
      super(attribute, *args)
    end
  end
end

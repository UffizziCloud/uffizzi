# frozen_string_literal: true

module UffizziCore::ApplicationFormWithoutActiveRecord
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Validations
    include ActiveModel::Conversion
    include ActiveModel::Serialization
    include ActiveModel::Validations::Callbacks
    include ::Virtus.model
  end

  def persisted?
    false
  end
end

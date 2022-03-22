# frozen_string_literal: true

class UffizziCore::BaseSerializer < ActiveModel::Serializer
  def anonymize(field)
    '*' * field.length
  end
end

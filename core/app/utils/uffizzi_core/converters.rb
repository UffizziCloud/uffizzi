# frozen_string_literal: true

module UffizziCore::Converters
  class << self
    include ActionView::Helpers::NumberHelper

    def deep_lower_camelize_keys(object)
      case object
      when Array
        object.map do |element|
          element.deep_transform_keys { |key| key.to_s.camelize(:lower) }
        end
      when Hash
        object.deep_transform_keys { |key| key.to_s.camelize(:lower) }
      else
        object
      end
    end

    def deep_underscore_keys(object)
      case object
      when Array
        object.map do |element|
          element.deep_transform_keys { |key| key.to_s.underscore }
        end
      when Hash
        object.deep_transform_keys { |key| key.to_s.underscore }
      else
        object
      end
    end
  end
end

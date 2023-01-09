# frozen_string_literal: true

class UffizziCore::ComposeFileError < StandardError
  attr_reader :errors

  def initialize(message, error_key = nil, extra_errors = {})
    if [NilClass, String].exclude?(error_key.class)
      raise StandardError.new("#{self.class} arg 'error_key' should be a #{String} or #{NilClass}")
    end

    unless extra_errors.is_a?(Hash)
      raise StandardError.new("#{self.class} arg 'extra_errors' should be a #{Hash}")
    end

    @errors = error_key.nil? ? {} : { error_key => message.to_s }.merge(extra_errors)

    super(message)
  end
end

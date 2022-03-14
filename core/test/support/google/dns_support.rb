# frozen_string_literal: true

module Google::Cloud::Dns
  def self.stub_new
    define_singleton_method(:new) do |*args|
      yield(*args)
    end
  end

  def self.new(*_args)
    raise 'This method is not yet mocked'
  end

  class Credentials
    def self.new(*_args)
      OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
    end
  end
end

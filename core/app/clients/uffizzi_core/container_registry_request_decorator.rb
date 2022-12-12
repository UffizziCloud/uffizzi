# frozen_string_literal: true

module UffizziCore::ContainerRegistryRequestDecorator
  [:get, :post, :head].each do |method|
    define_method(method) do |url, params_or_body = nil, headers = nil, &block|
      super(url, params_or_body, headers, &block)
    rescue Faraday::ClientError => e
      raise UffizziCore::ContainerRegistryError.new(e.response)
    end
  end
end

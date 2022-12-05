module UffizziCore::HttpRequestDecorator
  [:get, :post, :head].each do |method|
    define_method(method) do |url, params_or_body = nil, headers = nil|
      super(url, params_or_body, headers)
    rescue Faraday::ClientError => e
      raise UffizziCore::ContainerRegistryError.new(e.response)
    end
  end
end

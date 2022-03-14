# frozen_string_literal: true

require 'swagger_yard'

SwaggerYard.configure do |config|
  config.api_version = '1.0'

  config.title = 'Uffizzi docs'
  config.description = 'Your API does this'

  config.api_base_path = 'http://lvh.me:7000'

  config.controller_path = File.expand_path('app/controllers/uffizzi_core/api/**/*', UffizziCore::Engine.root)
  config.model_path = File.expand_path('app/models/uffizzi_core/**/*', UffizziCore::Engine.root)

  config.include_private = false
end

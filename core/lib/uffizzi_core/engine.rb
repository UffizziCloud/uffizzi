# frozen_string_literal: true

require 'active_model_serializers'

module UffizziCore
  class Engine < ::Rails::Engine
    isolate_namespace UffizziCore

    config.before_initialize do
      config.i18n.load_path += Dir["#{config.root}/config/locales/**/*.yml"]
    end

    ActiveModelSerializers.config.adapter = :json
  end
end

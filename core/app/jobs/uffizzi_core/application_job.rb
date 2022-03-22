# frozen_string_literal: true

module UffizziCore
  class ApplicationJob
    include Sidekiq::Worker
  end
end

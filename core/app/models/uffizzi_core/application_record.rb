# frozen_string_literal: true

module UffizziCore
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end

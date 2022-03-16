# frozen_string_literal: true

class UffizziCore::Project::Secret < ApplicationRecord
  self.table_name = Rails.application.config.uffizzi_core[:table_names][:project_secrets]

  belongs_to :project

  validates :name, presence: true
end

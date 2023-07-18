# frozen_string_literal: true

# This migration comes from uffizzi_core (originally 20230203071725)
class DeleteObsoleteFieldsFromRepo < ActiveRecord::Migration[6.1]
  def change
    remove_columns :uffizzi_core_repos, :deploy_preview_when_pull_request_is_opened, :delete_preview_when_pull_request_is_closed,
                   type: :boolean
  end
end

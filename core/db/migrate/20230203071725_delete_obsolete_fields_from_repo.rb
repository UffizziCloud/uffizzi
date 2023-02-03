class DeleteObsoleteFieldsFromRepo < ActiveRecord::Migration[6.1]
  def change
    remove_columns :uffizzi_core_repos, :deploy_preview_when_pull_request_is_opened, :delete_preview_when_pull_request_is_closed, type: :boolean
  end
end

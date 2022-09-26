# frozen_string_literal: true

class AddAdditionalSubdomainsToContainers < ActiveRecord::Migration[6.1]
  def change
    add_column(:uffizzi_core_containers, :additional_subdomains, :string, array: true, default: [])
  end
end

# frozen_string_literal: true

class AddStateToMemberships < ActiveRecord::Migration[6.1]
  def change
    add_column(:uffizzi_core_memberships, :state, :string)
  end
end

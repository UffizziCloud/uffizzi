# frozen_string_literal: true
# This migration comes from uffizzi_core (originally 20230111000000)

class AddStateToMemberships < ActiveRecord::Migration[6.1]
  def change
    add_column(:uffizzi_core_memberships, :state, :string)
  end
end

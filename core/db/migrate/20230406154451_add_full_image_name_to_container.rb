# frozen_string_literal: true

class AddFullImageNameToContainer < ActiveRecord::Migration[6.1]
  def change
    add_column(:uffizzi_core_containers, :full_image_name, :string)
  end
end

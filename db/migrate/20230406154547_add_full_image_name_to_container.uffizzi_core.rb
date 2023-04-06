# This migration comes from uffizzi_core (originally 20230406154451)
class AddFullImageNameToContainer < ActiveRecord::Migration[6.1]
  def up
    add_column(:uffizzi_core_containers, :full_image_name, :string)
  end

  def down
    remove_column(:uffizzi_core_containers, :full_image_name)
  end
end

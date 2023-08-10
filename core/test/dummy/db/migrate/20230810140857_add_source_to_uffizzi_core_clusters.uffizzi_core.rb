# This migration comes from uffizzi_core (originally 20230810140316)
class AddSourceToUffizziCoreClusters < ActiveRecord::Migration[6.1]
  def change
    add_column(:uffizzi_core_clusters, :creation_source, :string)
  end
end

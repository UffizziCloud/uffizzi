class AddSourceToUffizziCoreClusters < ActiveRecord::Migration[6.1]
  def change
    add_column(:uffizzi_core_clusters, :creation_source, :string)
  end
end

# frozen_string_literal: true

# This migration comes from uffizzi_core (originally 20231009162719)
class CreateUffizziCoreKubernetesDistributions < ActiveRecord::Migration[6.1]
  def change
    create_table :uffizzi_core_kubernetes_distributions do |t|
      t.string :version
      t.string :distro
      t.string :image
      t.boolean :default
      t.timestamps
    end
  end
end

# frozen_string_literal: true

class CreateUffizziCoreKubernetesDistributions < ActiveRecord::Migration[6.1]
  def change
    create_table :uffizzi_core_kubernetes_distributions do |t|
      t.string :version
      t.string :distro
      t.string :image
      t.boolean :default, default: false
      t.timestamps
    end
  end
end

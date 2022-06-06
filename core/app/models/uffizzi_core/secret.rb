# frozen_string_literal: true

class UffizziCore::Secret < ApplicationRecord
  self.table_name = UffizziCore.table_names[:secrets]

  belongs_to :resource, polymorphic: true

  validates :name, presence: true, uniqueness: { scope: :resource }
end

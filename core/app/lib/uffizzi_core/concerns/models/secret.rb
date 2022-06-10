# frozen_string_literal: true

module UffizziCore::Concerns::Models::Secret
  extend ActiveSupport::Concern

  included do
    self.table_name = UffizziCore.table_names[:secrets]

    belongs_to :resource, polymorphic: true

    validates :name, presence: true, uniqueness: { scope: :resource }
  end
end

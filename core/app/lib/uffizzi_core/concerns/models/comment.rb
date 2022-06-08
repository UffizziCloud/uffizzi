# frozen_string_literal: true

module UffizziCore::Concerns::Models::Comment
  extend ActiveSupport::Concern

  included do
    include UffizziCore::CommentRepo

    self.table_name = UffizziCore.table_names[:comments]

    has_ancestry(cache_depth: true)
    const_set(:MAX_DEPTH_LEVEL, 1)

    belongs_to :user
    belongs_to :commentable, polymorphic: true

    validates :content, length: { maximum: 1500 }, presence: true
    validates :ancestry_depth, numericality: { less_than_or_equal_to: self::MAX_DEPTH_LEVEL, only_integer: true }
  end
end

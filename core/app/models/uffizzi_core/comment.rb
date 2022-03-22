# frozen_string_literal: true

class UffizziCore::Comment < UffizziCore::ApplicationRecord
  include UffizziCore::CommentRepo

  self.table_name = Rails.application.config.uffizzi_core[:table_names][:comments]

  has_ancestry(cache_depth: true)
  MAX_DEPTH_LEVEL = 1

  belongs_to :user
  belongs_to :commentable, polymorphic: true

  validates :content, length: { maximum: 1500 }, presence: true
  validates :ancestry_depth, numericality: { less_than_or_equal_to: MAX_DEPTH_LEVEL, only_integer: true }
end

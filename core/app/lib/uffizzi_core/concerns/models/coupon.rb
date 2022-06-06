# frozen_string_literal: true

module UffizziCore::Concerns::Models::Coupon
  extend ActiveSupport::Concern

  included do
    self.table_name = UffizziCore.table_names[:coupons]
  end
end

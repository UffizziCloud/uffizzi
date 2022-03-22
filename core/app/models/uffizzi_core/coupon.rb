# frozen_string_literal: true

class UffizziCore::Coupon < UffizziCore::ApplicationRecord
  self.table_name = Rails.application.config.uffizzi_core[:table_names][:coupons]
end

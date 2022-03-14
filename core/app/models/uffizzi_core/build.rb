# frozen_string_literal: true

class UffizziCore::Build < UffizziCore::ApplicationRecord
  include UffizziCore::BuildRepo

  self.table_name = Rails.application.config.uffizzi_core[:table_names][:builds]

  BUILDING = 1
  SUCCESS = 2
  FAILED = 3
  TIMEOUT = 4
  CANCELLED = 5

  belongs_to :repo

  def successful?
    status == SUCCESS
  end

  def unsuccessful?
    [FAILED, TIMEOUT, CANCELLED].include?(status)
  end

  def failed?
    status == FAILED
  end

  def building?
    status == BUILDING
  end

  def timed_out?
    status == TIMEOUT
  end

  def cancelled?
    status == CANCELLED
  end
end

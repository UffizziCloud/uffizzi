# frozen_string_literal: true

module UffizziCore::Concerns::Models::Build
  extend ActiveSupport::Concern

  included do
    include UffizziCore::BuildRepo

    self.table_name = UffizziCore.table_names[:builds]

    const_set(:BUILDING, 1)
    const_set(:SUCCESS, 2)
    const_set(:FAILED, 3)
    const_set(:TIMEOUT, 4)
    const_set(:CANCELLED, 5)

    belongs_to :repo

    def successful?
      status == self.class::SUCCESS
    end

    def unsuccessful?
      [self.class::FAILED, self.class::TIMEOUT, self.class::CANCELLED].include?(status)
    end

    def failed?
      status == self.class::FAILED
    end

    def building?
      status == self.class::BUILDING
    end

    def timed_out?
      status == self.class::TIMEOUT
    end

    def cancelled?
      status == self.class::CANCELLED
    end
  end
end

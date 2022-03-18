# frozen_string_literal: true

class UffizziCore::ApplicationPolicy
  attr_reader :context, :record

  def initialize(context, record)
    raise Pundit::NotAuthorizedError, 'must be logged in' if !context.instance_of?(WebhooksContext) && context.user.blank?

    @record = record
    @context = context
  end
end

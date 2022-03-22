# frozen_string_literal: true

class UffizziCore::JsonResponder < ActionController::Responder
  def api_behavior(*args, &block)
    if post?
      display(resource, status: :created)
    elsif put? || patch?
      display(resource, status: :ok)
    else
      super
    end
  end
end

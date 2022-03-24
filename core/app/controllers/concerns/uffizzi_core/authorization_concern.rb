# frozen_string_literal: true

module UffizziCore::AuthorizationConcern
  extend ActiveSupport::Concern

  included do
    before_action :init_authorize
  end

  def init_authorize
    return unless self.class.ancestors.include?(UffizziCore::ApplicationController)

    self.class.send(:define_method, policy_method_name) { send(:authorize, policy_method_params) }
  end

  def pundit_user
    policy_context
  end

  private

  def policy_method_name
    [:authorize, policy_name].join('_')
  end

  def policy_name
    controller_class = self.class.to_s

    controller_class.gsub(/::|Controller/, '').underscore
  end

  def policy_method_params
    controller_class = self.class.to_s

    params = controller_class.gsub(/Controller/, '').split('::')
    params.map(&:underscore).map(&:downcase).map(&:to_sym)
  end
end

# frozen_string_literal: true

class UffizziCore::ClusterScaleError < StandardError
  def initialize(action)
    message = I18n.t('cluster.scaling_failed', action: action)

    super(message)
  end
end

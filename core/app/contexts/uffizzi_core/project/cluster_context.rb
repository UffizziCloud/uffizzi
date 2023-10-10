# frozen_string_literal: true

class UffizziCore::Project::ClusterContext
  attr_reader :user, :user_access_module, :project, :cluster, :params

  def initialize(user, project, user_access_module, cluster, params)
    @user = user
    @user_access_module = user_access_module
    @project = project
    @cluster = cluster
    @params = params
  end
end

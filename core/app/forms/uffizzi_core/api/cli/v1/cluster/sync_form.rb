# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Cluster::SyncForm < UffizziCore::Cluster
  include UffizziCore::ApplicationForm

  permit :state

  def sync_status
    cluster_data = UffizziCore::ControllerService.show_cluster(self)

    asleep_in_cluster = cluster_data.status.sleep
    return if actual_status?(asleep_in_cluster)

    self.state = scaled_down ? UffizziCore::Cluster::STATE_SCALED_DOWN : UffizziCore::Cluster::STATE_DEPLOYED

    self
  end

  private

  def actual_status?(actually_asleep)
    (asleep_in_cluster && scaled_down?) || (!asleep_in_cluster && deployed?)
  end
end

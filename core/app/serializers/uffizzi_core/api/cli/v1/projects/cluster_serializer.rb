# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::ClusterSerializer < UffizziCore::BaseSerializer
  type :cluster

  attributes :id, :name, :namespace, :kubeconfig_content

  def kubeconfig_content
    'test_kubeconfig'
    # instance_options[:kubeconfig_content]
  end
end

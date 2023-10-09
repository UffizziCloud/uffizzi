# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Cluster::CreateForm < UffizziCore::Cluster
  include UffizziCore::ApplicationForm

  permit :name, :manifest, :creation_source, :k8s_version

  validate :check_manifest, if: -> { manifest.present? }

  private

  def check_manifest
    YAML.load_stream(manifest)
  rescue Psych::SyntaxError => e
    err = [e.problem, e.context].compact.join(' ')

    errors.add(:manifest, err)
  end
end

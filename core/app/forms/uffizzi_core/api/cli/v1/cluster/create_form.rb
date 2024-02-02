# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Cluster::CreateForm < UffizziCore::Cluster
  include UffizziCore::ApplicationForm

  permit :name, :manifest, :creation_source, :kind

  validate :check_manifest, if: -> { manifest.present? }
  validates_uniqueness_of :deployed_by_id, conditions: -> { enabled }, scope: [:project_id, :kind], if: Proc.new { |c| c.kind.dev? }
  private

  def check_manifest
    YAML.load_stream(manifest)
  rescue Psych::SyntaxError => e
    err = [e.problem, e.context].compact.join(' ')

    errors.add(:manifest, err)
  end
end

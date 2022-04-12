# frozen_string_literal: true

class UffizziCore::Repo < UffizziCore::ApplicationRecord
  extend Enumerize
  include UffizziCore::RepoRepo

  self.table_name = Rails.application.config.uffizzi_core[:table_names][:repos]

  enumerize :kind, in: [:buildpacks18, :dockerfile, :dotnet, :gatsby, :barestatic], predicates: true

  belongs_to :project
  has_one :container, inverse_of: :repo, dependent: :destroy
  has_many :builds, dependent: :destroy

  validates :dockerfile_path, presence: true, if: :dockerfile?
  validates :delete_preview_after, numericality: { greater_than: 0, only_integer: true }, allow_nil: true

  def docker_hub?
    type == UffizziCore::Repo::DockerHub.name
  end

  def azure?
    type == UffizziCore::Repo::Azure.name
  end

  def google?
    type == UffizziCore::Repo::Google.name
  end
end

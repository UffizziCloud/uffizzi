# frozen_string_literal: true

module UffizziCore::Concerns::Models::Template
  extend ActiveSupport::Concern

  included do
    include UffizziCore::TemplateRepo
    extend Enumerize

    self.table_name = UffizziCore.table_names[:templates]

    belongs_to :added_by, class_name: UffizziCore::User.name, foreign_key: :added_by_id
    belongs_to :project, touch: true
    belongs_to :compose_file, optional: true

    has_many :deployments, dependent: :nullify

    enumerize :creation_source, in: [:manual, :compose_file, :system], predicates: true, scope: true

    validates :name, presence: true
    validates :name, uniqueness: { scope: :project }, if: -> { compose_file.blank? || compose_file.kind.main? }

    def valid_containers_memory_limit?
      containers_attributes = payload['containers_attributes']
      container_memory_limit = project.account.container_memory_limit
      return true if container_memory_limit.nil?

      containers_attributes.all? { |container| container['memory_limit'].to_i <= container_memory_limit }
    end

    def valid_containers_memory_request?
      containers_attributes = payload['containers_attributes']
      container_memory_limit = project.account.container_memory_limit
      return true if container_memory_limit.nil?

      containers_attributes.all? { |container| container['memory_request'].to_i <= container_memory_limit }
    end
  end
end

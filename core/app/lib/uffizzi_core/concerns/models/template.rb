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

    def valid_memory_limit?
      UffizziCore::TemplateService.valid_memory_limit?(self)
    end

    def valid_memory_request?
      UffizziCore::TemplateService.valid_memory_request?(self)
    end
  end
end

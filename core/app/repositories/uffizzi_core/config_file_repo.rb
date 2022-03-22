# frozen_string_literal: true

module UffizziCore::ConfigFileRepo
  extend ActiveSupport::Concern

  included do
    scope :by_deployment, ->(deployment) {
      select(:id)
        .joins(:container_config_files)
        .where(container_config_files: { container: deployment.containers })
        .distinct
    }

    scope :by_source, ->(source) {
      where(source: source)
    }

    scope :only_used_config_files, -> {
      select(:id)
        .where("(id = ANY(ARRAY(select distinct(
                 jsonb_array_elements(
                   (
                     jsonb_array_elements(
                       jsonb_extract_path_text(
                         payload::jsonb, 'containers_attributes'
                       )::jsonb
                     ) ->> 'container_config_files_attributes'
                   )::jsonb
                 ) ->> 'config_file_id'
               ) as ids from templates)::int[]))")
        .or(
          UffizziCore::ConfigFile.where(
            id: UffizziCore::ContainerConfigFile.where(
              container_id: UffizziCore::Container.active.select(:id),
            ).select(:config_file_id),
          ),
        )
    }
  end
end

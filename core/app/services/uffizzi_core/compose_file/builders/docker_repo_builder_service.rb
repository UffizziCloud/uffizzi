# frozen_string_literal: true

class UffizziCore::ComposeFile::Builders::DockerRepoBuilderService
  attr_accessor :type

  def initialize(type)
    @type = type
  end

  def build_attributes(image_data)
    {
      kind: nil,
      name: image_data[:name],
      slug: image_data[:name],
      type: type,
      branch: nil,
      namespace: image_data[:namespace],
      is_private: nil, # TODO: detect
      description: '',
      repository_id: nil,
      dockerfile_path: '',
      dockerfile_context_path: nil,
    }
  end
end

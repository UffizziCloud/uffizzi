# frozen_string_literal: true

module UffizziCore::HashidConcern
  extend ActiveSupport::Concern

  class_methods do
    def hashid_service
      @hashid_service ||= Hashids.new("#{Rails.application.secrets.secret_key_base}-#{name}")
    end

    def find_by_hashid(hashid)
      id = hashid_service.decode(hashid.to_s).first
      find_by(id: id)
    end

    def find_by_hashid!(hashid)
      id = hashid_service.decode(hashid.to_s).first
      find(id)
    end
  end

  def hashid
    self.class.hashid_service.encode(id)
  end
end

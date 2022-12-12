# frozen_string_literal: true

class UffizziCore::Credential < UffizziCore::ApplicationRecord
  include UffizziCore::Concerns::Models::Credential

  enumerize :type,
            in: self::CREDENTIAL_TYPES, i18n_scope: ['enumerize.credential.type']
end

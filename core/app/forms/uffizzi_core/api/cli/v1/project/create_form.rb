# frozen_string_literal: true

class UffizziCore::Project::CreateForm < UffizziCore::Project
  include ApplicationForm

  permit :name, :slug, :description

  validates :name, presence: true, uniqueness: { scope: :account }
  validates :slug, presence: true, uniqueness: true
end

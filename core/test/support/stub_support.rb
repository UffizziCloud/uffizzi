# frozen_string_literal: true

module UffizziCore::StubSupport
  def stub_controller
    stub_request(:any, /#{Regexp.quote(Settings.controller.url.to_s)}\/*./)
  end
end

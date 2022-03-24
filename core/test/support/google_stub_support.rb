# frozen_string_literal: true

module UffizziCore::GoogleStubSupport
  def google_build_stub
    Google::Cloud::Build.stubs(:cloud_build).returns(Google::Cloud::BuildMock.new)
  end
end

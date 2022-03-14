# frozen_string_literal: true

module UffizziCore::GoogleStubSupport
  def google_dns_stub
    Google::Cloud::Dns.stub_new do |*_args|
      credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
      dns = Google::Cloud::Dns::Project.new(Google::Cloud::Dns::Service.new(generate(:string), credentials))

      dns
    end
  end

  def google_build_stub
    Google::Cloud::Build.stubs(:cloud_build).returns(Google::Cloud::BuildMock.new)
  end
end

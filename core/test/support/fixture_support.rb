# frozen_string_literal: true

module UffizziCore::FixtureSupport
  def file_fixture(file_path)
    full_path = "#{ActiveSupport::TestCase.fixture_path}/#{file_path}"
    File.new(full_path)
  end

  def json_fixture(file_path, symbolize_names: true)
    data = file_fixture(file_path).read
    JSON.parse(data, symbolize_names: symbolize_names)
  end
end

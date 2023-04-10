# frozen_string_literal: true

require 'test_helper'

class UffizziCore::ImageParserServiceTest < ActiveSupport::TestCase
  test '#parse' do
    image_parser_service = UffizziCore::ComposeFile::Parsers::Services::ImageParserService
    assert_equal(
      { registry_url: nil, namespace: 'library', name: 'redis', tag: 'latest', full_image_name: 'docker.io/library/redis:latest' },
      image_parser_service.parse('redis'),
    )
    assert_equal(
      { registry_url: nil, namespace: 'library', name: 'redis', tag: '5', full_image_name: 'docker.io/library/redis:5' },
      image_parser_service.parse('redis:5'),
    )
    assert_equal(
      { registry_url: nil, namespace: 'namespace', name: 'redis', tag: 'latest', full_image_name: 'docker.io/namespace/redis:latest' },
      image_parser_service.parse('namespace/redis'),
    )
    assert_equal(
      { registry_url: nil, namespace: 'namespace', name: 'redis', tag: 'latest',
        full_image_name: 'docker.io/namespace/redis:latest' },
      image_parser_service.parse('docker.io/namespace/redis'),
    )
    assert_equal(
      { registry_url: 'my-private.registry:5000', namespace: 'namespace', name: 'redis', tag: '5.3',
        full_image_name: 'my-private.registry:5000/namespace/redis:5.3' },
      image_parser_service.parse('my-private.registry:5000/namespace/redis:5.3'),
    )
    assert_equal(
      { registry_url: 'localhost:80', namespace: nil, name: 'redis', tag: '5.3', full_image_name: 'localhost:80/redis:5.3' },
      image_parser_service.parse('localhost:80/redis:5.3'),
    )
    assert_equal(
      { registry_url: nil, namespace: 'library', name: 'lower_case_name', tag: 'lower_case_tag',
        full_image_name: 'docker.io/library/lower_case_name:lower_case_tag' },
      image_parser_service.parse('lower_case_name:lower_case_tag'),
    )
    # assert_equal(
    #   { registry_url: nil, namespace: 'library', name: 'lower_case_name', tag: 'UPPERCASE_TAG',
    #     full_image_name: 'docker.io/library/lower_case_name:UPPERCASE_TAG' },
    #   image_parser_service.parse('lower_case_name:UPPERCASE_TAG'),
    # )
  end

  test '#parse with exception' do
    image_parser_service = UffizziCore::ComposeFile::Parsers::Services::ImageParserService
    assert_raises(UffizziCore::ComposeFile::ParseError) { image_parser_service.parse('very:wrong:image:path') }
    assert_raises(UffizziCore::ComposeFile::ParseError) { image_parser_service.parse('UPPERCASE_NAMESPACE/UPPERCASE_NAME:UPPERCASE_TAG') }
    assert_raises(UffizziCore::ComposeFile::ParseError) { image_parser_service.parse('UPPERCASE_NAME:UPPERCASE_TAG') }
    assert_raises(UffizziCore::ComposeFile::ParseError) { image_parser_service.parse('UPPERCASE_NAME') }
  end
end

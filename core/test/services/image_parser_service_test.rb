# frozen_string_literal: true

require 'test_helper'

class UffizziCore::ImageParserServiceTest < ActiveSupport::TestCase
  test '#parse' do
    image_parser_service = UffizziCore::ComposeFile::Parsers::Services::ImageParserService
    assert_equal(
      { registry_url: nil, namespace: 'library', name: 'redis', tag: 'latest' },
      image_parser_service.parse('redis'),
    )
    assert_equal(
      { registry_url: nil, namespace: 'library', name: 'redis', tag: '5' },
      image_parser_service.parse('redis:5'),
    )
    assert_equal(
      { registry_url: nil, namespace: 'namespace', name: 'redis', tag: 'latest' },
      image_parser_service.parse('namespace/redis'),
    )
    assert_equal(
      { registry_url: 'docker.io:443', namespace: 'namespace', name: 'redis', tag: 'latest' },
      image_parser_service.parse('docker.io/namespace/redis'),
    )
    assert_equal(
      { registry_url: 'my_private.registry:5000', namespace: 'namespace', name: 'redis', tag: '5.3' },
      image_parser_service.parse('my_private.registry:5000/namespace/redis:5.3'),
    )
    assert_equal(
      { registry_url: 'localhost:80', namespace: nil, name: 'redis', tag: '5.3' },
      image_parser_service.parse('localhost:80/redis:5.3'),
    )
    assert_equal(
      { registry_url: nil, namespace: 'namespace', name: 'redis', tag: 'RELEASE.2021-12-18T04-42-33Z' },
      image_parser_service.parse('NAMESPACE/REDIS:RELEASE.2021-12-18T04-42-33Z'),
    )
    assert_equal(
      { registry_url: nil, namespace: 'library', name: 'uffizzi', tag: 'RELEASE.2021-12-18T04-42-33Z' },
      image_parser_service.parse('UFFIZZI:RELEASE.2021-12-18T04-42-33Z'),
    )
    assert_equal(
      { registry_url: nil, namespace: 'library', name: 'uffizzi', tag: 'latest' },
      image_parser_service.parse('UFFIZZI'),
    )
  end

  test '#parse with exception' do
    image_parser_service = UffizziCore::ComposeFile::Parsers::Services::ImageParserService
    assert_raises(UffizziCore::ComposeFile::ParseError) { image_parser_service.parse('very:wrong:image:path') }
  end
end

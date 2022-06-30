# frozen_string_literal: true

require 'test_helper'

class UffizziCore::ComposeFileServiceTest < ActiveSupport::TestCase
  setup do
    @user = create(:user, :with_organizational_account)
    @account = @user.organizational_account
    @project = create(:project, account: @account)
  end

  test '#parse - check parse services with continuous preview' do
    content = file_fixture('files/compose_files/compose_with_continuous_preview.yml').read

    parsed_data = UffizziCore::ComposeFileService.parse(content)

    assert_equal(2, parsed_data[:containers].count)
    refute_empty(parsed_data[:continuous_preview])
    refute_empty(parsed_data[:containers][1][:'x-uffizzi-continuous-preview'])
  end

  test '#parse - check invalid service name' do
    content = file_fixture('files/compose_files/invalid_service.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match('Invalid config option', e.message)
  end

  test '#parse - check parse docker image' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx.yml').read

    parsed_data = UffizziCore::ComposeFileService.parse(content)

    assert_equal(1, parsed_data[:containers].count)
    refute_empty(parsed_data[:containers].first[:image])
  end

  test '#parse - check parse docker image without tag' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx_without_tag.yml').read

    parsed_data = UffizziCore::ComposeFileService.parse(content)

    container = parsed_data[:containers].first
    image = container[:image]
    tag = image[:tag]

    assert_equal(Settings.compose.default_tag, tag)
  end

  test '#parse - check parse env variables from an environment key' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx_envs.yml').read

    parsed_data = UffizziCore::ComposeFileService.parse(content)

    content_data = YAML.safe_load(content)
    variables = parsed_data[:containers].first[:environment]

    assert_equal(variables.count, content_data['services']['hello-world']['environment'].keys.count)
  end

  test '#parse - check invalid ingress service' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx_config_invalid_ingress_service.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match('Invalid ingress service', e.message)
  end

  test '#parse - check if an ingress service not found' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx_without_ingress_service.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match('Ingress service not found', e.message)
  end

  test '#parse - check if an ingress port not specified' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx_without_ingress_port.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match('Ingress port not specified', e.message)
  end

  test '#parse - check if an ingress port is not Integer' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx_ingress_port_non_integer.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match('should be an Integer type', e.message)
  end

  test '#parse - check compose without ingress' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx_without_ingress.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match('Service ingress has not been defined', e.message)
  end

  test '#parse - check compose with ingress without x-uffizzi' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx_with_ingress_without_x-uffizzi.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match('Service ingress has not been defined', e.message)
  end

  test '#parse - check compose with continuous_preview on top level without x-uffizzi' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx_with_continuous_preview_without_x-uffizzi.yml').read

    parsed_data = UffizziCore::ComposeFileService.parse(content)

    assert_empty(parsed_data[:continuous_preview])
  end

  test '#parse - check compose with continuous_preview on service level without x-uffizzi' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx_with_continuous_preview_without_x-uffizzi.yml').read

    parsed_data = UffizziCore::ComposeFileService.parse(content)

    refute(parsed_data[:containers][0][:'x-uffizzi-continuous-preview'])
  end

  test '#parse - check compose without services' do
    content = file_fixture('files/compose_files/compose_without_services.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match('At least one must be provided', e.message)
  end

  test '#parse - check if a port is  out of acceptable range' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx_invalid_port.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match("Port should be specified between #{Settings.compose.port_min_value} - #{Settings.compose.port_max_value}", e.message)
  end

  test '#parse - check if a memory has invalid postfix' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx_invalid_memory_postfix.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match('The postfix should be one of', e.message)
  end

  test '#parse - check if a memory has invalid type' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx_invalid_memory_type.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match('it should be a string', e.message)
  end

  test '#parse - check if image and build data no specified' do
    content = file_fixture('files/compose_files/compose_without_image.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match('At least one must be provided', e.message)
  end

  test '#parse - check if delete_preview_after has invalid postfix' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx_cp_invalid_delete_after_postfix.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match('value should be `h`', e.message)
  end

  test '#parse - check if delete_preview_after has invalid value' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx_cp_invalid_delete_after_hours.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match('should be an Integer type', e.message)
  end

  test '#parse - check if delete_preview_after less than min value' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx_cp_invalid_delete_after_min.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match('Minimum delete_preview_after', e.message)
  end

  test '#parse - check if delete_preview_after more than max value' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx_cp_invalid_delete_after_max.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match('Maximum delete_preview_after', e.message)
  end

  test '#parse - check if delete_preview_after has only integer value' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx_cp_delete_after_integer.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match('should be a String type', e.message)
  end

  test '#parse - check if deploy auto is invalid' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx_invalid_deploy_auto.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match('Invalid auto value', e.message)
  end

  test '#parse - check if an env_file is empty' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx_env_file_empty.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match("Unsupported type of 'env_file'", e.message)
  end

  test '#parse - check if a list of env files has an empty value' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx_env_file_empty_in_array.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match('env_file contains an empty value', e.message)
  end

  test '#parse - check if a list of env files has duplicated values' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx_env_file_duplicates.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match('env_file contains non-unique items', e.message)
  end

  test '#parse - check a boolean option' do
    content = file_fixture('files/compose_files/boolean_option.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match('The service name true must be a quoted string', e.message)
  end

  test '#parse - check if a config is unknown in short syntax' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx_configs_short_syntax_unknown_config.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match('undefined config', e.message)
  end

  test '#parse - check if a config path is not specified' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx_configs_short_syntax_invalid_path.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match('has an empty file', e.message)
  end

  test '#parse - check parse configs with a long syntax' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx_configs_long_syntax.yml').read

    parsed_content = UffizziCore::ComposeFileService.parse(content)

    content_data = YAML.safe_load(content)
    config = parsed_content[:containers].first[:configs].first

    assert_equal(content_data['services']['nginx']['configs'].first['target'], config[:target])
  end

  test '#parse - check parse configs with a long syntax if a target is not specified' do
    content = file_fixture('files/compose_files/dockerhub_services/nginx_configs_long_syntax_without_target.yml').read

    parsed_content = UffizziCore::ComposeFileService.parse(content)

    content_data = YAML.safe_load(content)
    config = parsed_content[:containers].first[:configs].first

    assert_equal(content_data['configs']['vote_conf']['file'], config[:target])
  end

  test '#parse - check if a secret is unknown' do
    content = file_fixture('files/compose_files/dockerhub_services/postgres_secrets_unknown.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match('undefined secret', e.message)
  end

  test '#parse - check if a secret is not external' do
    content = file_fixture('files/compose_files/dockerhub_services/postgres_secrets_without_external.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match("'postgres_password' should be external", e.message)
  end

  test '#parse - check if a secret doesn\'t have a name' do
    content = file_fixture('files/compose_files/dockerhub_services/postgres_secrets_without_name.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match("'postgres_password' secret can not be blank", e.message)
  end

  test '#parse - raise an error if a build option is specified' do
    content = file_fixture('files/compose_files/github_services/hello_world.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match("'build' option is not implemented", e.message)
  end

  test '#parse - parses compose file with healthcheck and converts time to seconds when the test command is array' do
    content = file_fixture('files/compose_files/healthcheck/array_command_success.yml').read

    result = UffizziCore::ComposeFileService.parse(content)
    container_with_healthcheck = result[:containers].select { |container| container[:container_name] == 'hello-world' }.first

    assert_equal(90, container_with_healthcheck[:healthcheck][:interval])
    refute(container_with_healthcheck[:healthcheck][:disable])
  end

  test '#parse - parses compose file with healthcheck and converts time to seconds when the test command is string' do
    content = file_fixture('files/compose_files/healthcheck/string_command_success.yml').read

    result = UffizziCore::ComposeFileService.parse(content)
    container_with_healthcheck = result[:containers].select { |container| container[:container_name] == 'hello-world' }.first

    assert_equal(90, container_with_healthcheck[:healthcheck][:interval])
    refute(container_with_healthcheck[:healthcheck][:disable])
  end

  test "#parse - parses compose file with healthcheck and sets disabled to false if the command is 'NONE'" do
    content = file_fixture('files/compose_files/healthcheck/disabled_healthcheck.yml').read

    result = UffizziCore::ComposeFileService.parse(content)
    container_with_healthcheck = result[:containers].select { |container| container[:container_name] == 'hello-world' }.first

    assert(container_with_healthcheck[:healthcheck][:disable])
  end

  test '#parse - raises error if the healthcheck command has invalid type' do
    content = file_fixture('files/compose_files/healthcheck/invalid_command.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match("Unsupported type of 'test' option", e.message)
  end

  test '#parse - raises error if the retries field has invalid type' do
    content = file_fixture('files/compose_files/healthcheck/invalid_retries.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    assert_match('The specified value for retries should be an Integer type', e.message)
  end

  test '#parse - raises error if healthcheck has invalid interval' do
    content = file_fixture('files/compose_files/healthcheck/invalid_interval.yml').read

    e = assert_raise(UffizziCore::ComposeFile::ParseError) do
      UffizziCore::ComposeFileService.parse(content)
    end

    error_message = "The time interval should be in the following format '{hours}h{minutes}m{seconds}s'. " \
                    'At least one value must be present.'
    assert_match(error_message, e.message)
  end

  test '#build_template_attributes - check if x-uffizzi ingress is specified' do
    create(:credential, :docker_hub, account: @account)
    content = file_fixture('files/compose_files/dockerhub_services/nginx_uffizzi_ingress.yml').read
    parsed_data = UffizziCore::ComposeFileService.parse(content)

    attributes = UffizziCore::ComposeFileService.build_template_attributes(parsed_data, 'compose.yml', @account.credentials, @project)

    content_data = YAML.safe_load(content)
    nginx_container = attributes[:payload][:containers_attributes].detect { |container| container[:image].match(/nginx/) }

    assert(nginx_container[:public])
    assert_equal(nginx_container[:port], content_data['x-uffizzi']['ingress']['port'])
  end

  test '#build_template_attributes - check if deploy auto is disabled' do
    create(:credential, :docker_hub, account: @account)
    content = file_fixture('files/compose_files/dockerhub_services/nginx_auto_deploy_off.yml').read
    parsed_data = UffizziCore::ComposeFileService.parse(content)

    attributes = UffizziCore::ComposeFileService.build_template_attributes(parsed_data, 'compose.yml', @account.credentials, @project)

    continuously_deploy = attributes[:payload][:containers_attributes].first[:continuously_deploy]
    assert_equal(:disabled, continuously_deploy)
  end

  test '#build_template_attributes - check container default memory' do
    create(:credential, :docker_hub, account: @account)
    content = file_fixture('files/compose_files/dockerhub_services/nginx.yml').read
    parsed_data = UffizziCore::ComposeFileService.parse(content)

    attributes = UffizziCore::ComposeFileService.build_template_attributes(parsed_data, 'compose.yml', @account.credentials, @project)

    memory_limit = attributes[:payload][:containers_attributes].first[:memory_limit]
    assert_equal(Settings.compose.default_memory, memory_limit)
  end

  test '#build_template_attributes - check if a memory is not in list of available values' do
    create(:credential, :docker_hub, account: @account)
    content = file_fixture('files/compose_files/dockerhub_services/nginx_invalid_memory.yml').read
    parsed_data = UffizziCore::ComposeFileService.parse(content)

    e = assert_raise(UffizziCore::ComposeFile::BuildError) do
      UffizziCore::ComposeFileService.build_template_attributes(parsed_data, 'compose.yml', @account.credentials, @project)
    end

    assert_match('The memory should be one of the', e.message)
  end

  test '#build_template_attributes - check container memory' do
    create(:credential, :docker_hub, account: @account)
    content = file_fixture('files/compose_files/compose_memory.yml').read
    parsed_data = UffizziCore::ComposeFileService.parse(content)

    attributes = UffizziCore::ComposeFileService.build_template_attributes(parsed_data, 'compose.yml', @account.credentials, @project)

    postgres_container = attributes[:payload][:containers_attributes].detect { |container| container[:image].match(/postgres/) }
    redis_container = attributes[:payload][:containers_attributes].detect { |container| container[:image].match(/redis/) }
    nginx_container = attributes[:payload][:containers_attributes].detect { |container| container[:image].match(/nginx/) }
    ubuntu_container = attributes[:payload][:containers_attributes].detect { |container| container[:image].match(/ubuntu/) }

    assert_equal(125, postgres_container[:memory_limit])
    assert_equal(250, redis_container[:memory_limit])
    assert_equal(1000, nginx_container[:memory_limit])
    assert_equal(4000, ubuntu_container[:memory_limit])
  end

  test '#build_template_attributes - check azure image build' do
    create(:credential, :azure, account: @account)
    content = file_fixture('files/compose_files/azure_services/nginx.yml').read
    parsed_data = UffizziCore::ComposeFileService.parse(content)

    attributes = UffizziCore::ComposeFileService.build_template_attributes(parsed_data, 'compose.yml', @account.credentials, @project)

    container = attributes[:payload][:containers_attributes].first
    content_data = YAML.safe_load(content)

    image_url = content_data['services']['nginx']['image'].split(':').first
    tag = content_data['services']['nginx']['image'].split(':').last
    image_name = image_url.split('/').last

    assert_equal(container[:image], image_name)
    assert_equal(container[:tag], tag)
    assert_equal(container[:repo_attributes][:name], image_name)
    refute(container[:repo_attributes][:namespace])
    assert_equal(container[:repo_attributes][:type], UffizziCore::Repo::Azure.name)
  end

  test '#build_template_attributes - check invalid azure credential' do
    content = file_fixture('files/compose_files/azure_services/nginx.yml').read
    parsed_data = UffizziCore::ComposeFileService.parse(content)

    e = assert_raise(UffizziCore::ComposeFile::BuildError) do
      UffizziCore::ComposeFileService.build_template_attributes(parsed_data, 'compose.yml', @account.credentials, @project)
    end

    assert_match("Invalid credential 'azure'", e.message)
  end

  test '#build_template_attributes - check google image build' do
    create(:credential, :google, account: @account)
    content = file_fixture('files/compose_files/google_services/nginx.yml').read
    parsed_data = UffizziCore::ComposeFileService.parse(content)

    attributes = UffizziCore::ComposeFileService.build_template_attributes(parsed_data, 'compose.yml', @account.credentials, @project)

    container = attributes[:payload][:containers_attributes].first
    content_data = YAML.safe_load(content)

    image_url = content_data['services']['nginx']['image'].split(':').first
    tag = content_data['services']['nginx']['image'].split(':').last
    project_name = image_url.split('/').second
    image_name = image_url.split('/').last

    assert_equal(container[:image], "#{project_name}/#{image_name}")
    assert_equal(container[:tag], tag)
    assert_equal(container[:repo_attributes][:name], image_name)
    assert_equal(container[:repo_attributes][:namespace], project_name)
    assert_equal(container[:repo_attributes][:type], UffizziCore::Repo::Google.name)
  end

  test '#build_template_attributes - check build of custom docker account' do
    create(:credential, :docker_hub, account: @account)
    content = file_fixture('files/compose_files/dockerhub_services/account_custom_image.yml').read

    parsed_data = UffizziCore::ComposeFileService.parse(content)
    attributes = UffizziCore::ComposeFileService.build_template_attributes(parsed_data, 'compose.yml', @account.credentials, @project)

    container = attributes[:payload][:containers_attributes].first
    content_data = YAML.safe_load(content)

    image_url = content_data['services']['nginx']['image'].split(':').first
    tag = content_data['services']['nginx']['image'].split(':').last
    account_name = image_url.split('/').first
    image_name = image_url.split('/').last

    assert_equal(container[:image], "#{account_name}/#{image_name}")
    assert_equal(container[:tag], tag)
    assert_equal(container[:repo_attributes][:name], image_name)
    assert_equal(container[:repo_attributes][:namespace], account_name)
    assert_equal(container[:repo_attributes][:type], UffizziCore::Repo::DockerHub.name)
  end

  test '#build_template_attributes - check a command build' do
    create(:credential, :google, account: @account)
    content = file_fixture('files/compose_files/google_services/cloudsql.yml').read
    parsed_data = UffizziCore::ComposeFileService.parse(content)

    attributes = UffizziCore::ComposeFileService.build_template_attributes(parsed_data, 'compose.yml', @account.credentials, @project)

    container = attributes[:payload][:containers_attributes].last

    refute_nil(container[:command])
    assert_nil(container[:entrypoint])
  end

  test '#build_template_attributes - check an entrypoint build' do
    create(:credential, :google, account: @account)
    content = file_fixture('files/compose_files/google_services/cloudsql_entrypoint.yml').read
    parsed_data = UffizziCore::ComposeFileService.parse(content)

    attributes = UffizziCore::ComposeFileService.build_template_attributes(parsed_data, 'compose.yml', @account.credentials, @project)

    container = attributes[:payload][:containers_attributes].last

    refute_nil(container[:entrypoint])
    assert_nil(container[:command])
  end

  test '#build_template_attributes - check secrets variables build' do
    project_secrets = [build(:secret, name: 'POSTGRES_USER', value: generate(:string)),
                       build(:secret, name: 'POSTGRES_PASSWORD', value: generate(:string))]
    @project.secrets.append(project_secrets)
    create(:credential, :docker_hub, account: @account)

    content = file_fixture('files/compose_files/dockerhub_services/postgres_secrets.yml').read
    parsed_data = UffizziCore::ComposeFileService.parse(content)

    attributes = UffizziCore::ComposeFileService.build_template_attributes(parsed_data, 'compose.yml', @account.credentials, @project)

    content_data = YAML.safe_load(content)

    postgres_container = attributes[:payload][:containers_attributes].detect { |container| container[:image].match(/postgres/) }
    secret_variables = postgres_container[:secret_variables]

    assert_equal(2, secret_variables.size)
    refute_nil(secret_variables.detect { |secret| secret[:name] == content_data['secrets']['postgres_user']['name'] })
    refute_nil(secret_variables.detect { |secret| secret[:name] == content_data['secrets']['postgres_password']['name'] })
  end

  test '#build_template_attributes - check secrets variables build if a project secret doesn\'t exist' do
    create(:credential, :docker_hub, account: @account)

    content = file_fixture('files/compose_files/dockerhub_services/postgres_secrets.yml').read
    parsed_data = UffizziCore::ComposeFileService.parse(content)

    e = assert_raise(UffizziCore::ComposeFile::SecretsError) do
      UffizziCore::ComposeFileService.build_template_attributes(parsed_data, 'compose.yml', @account.credentials, @project)
    end

    assert_match("Project secret 'POSTGRES_USER' not found", e.message)
  end

  test '#build_template_attributes - check secrets variables build if a compose has duplicates' do
    project_secrets = [build(:secret, name: 'POSTGRES_USER', value: generate(:string)),
                       build(:secret, name: 'POSTGRES_PASSWORD', value: generate(:string))]
    @project.secrets.append(project_secrets)
    create(:credential, :docker_hub, account: @account)

    content = file_fixture('files/compose_files/dockerhub_services/postgres_secrets_duplicates.yml').read
    parsed_data = UffizziCore::ComposeFileService.parse(content)

    attributes = UffizziCore::ComposeFileService.build_template_attributes(parsed_data, 'compose.yml', @account.credentials, @project)

    content_data = YAML.safe_load(content)

    postgres_container = attributes[:payload][:containers_attributes].detect { |container| container[:image].match(/postgres/) }
    secret_variables = postgres_container[:secret_variables]

    assert_equal(1, secret_variables.size)
    refute_nil(secret_variables.detect { |secret| secret[:name] == content_data['secrets']['postgres_user']['name'] })
    assert_nil(secret_variables.detect { |secret| secret[:name] == 'POSTGRES_PASSWORD' })
  end

  test '#build_template_attributes - check global and container continuous preview attributes' do
    create(:credential, :docker_hub, account: @account)

    content = file_fixture('files/compose_files/compose_with_continuous_preview.yml').read
    parsed_data = UffizziCore::ComposeFileService.parse(content)

    attributes = UffizziCore::ComposeFileService.build_template_attributes(parsed_data, 'compose.yml', @account.credentials, @project)

    nginx_repo_attributes = attributes[:payload][:containers_attributes].detect { |item| item[:image] == 'library/nginx' }[:repo_attributes]
    redis_repo_attributes = attributes[:payload][:containers_attributes].detect { |item| item[:image] == 'library/redis' }[:repo_attributes]

    assert { nginx_repo_attributes[:delete_preview_after] == 12 }
    assert { redis_repo_attributes[:delete_preview_after] == 10 }
  end

  test '#build_template_attributes - check named volumes' do
    create(:credential, :docker_hub, account: @account)
    content = file_fixture('files/compose_files/dockerhub_services/volumes_named.yml').read
    parsed_data = UffizziCore::ComposeFileService.parse(content)
    attributes = UffizziCore::ComposeFileService.build_template_attributes(parsed_data, 'compose.yml', @account.credentials, @project)

    content_data = YAML.safe_load(content)
    nginx_container = attributes[:payload][:containers_attributes].detect { |container| container[:image].match(/nginx/) }
    first_volume = nginx_container[:volumes].first

    assert(nginx_container[:volumes])
    assert_equal(UffizziCore::ComposeFile::Parsers::Services::VolumesParserService::NAMED_VOLUME_TYPE, first_volume[:type])
    assert_equal(content_data.dig('services', 'nginx', 'volumes').first.split(':').first, first_volume[:source])
    assert_equal(content_data.dig('services', 'nginx', 'volumes').first.split(':').second, first_volume[:target])
  end
end

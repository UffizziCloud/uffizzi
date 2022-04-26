# frozen_string_literal: true

class UffizziCore::StarterTemplateService
  class << self
    def create(project, user)
      voting_app_config_file = create_config_file(project, user)
      create_containers(project, user, voting_app_config_file)
    end

    private

    def create_config_file(project, user)
      starter_template_config_file = config_file_attributes

      starter_template_config_file_params = ActionController::Parameters.new(starter_template_config_file)

      starter_template_config_file_form = UffizziCore::Api::Cli::V1::ConfigFile::CreateForm.new(starter_template_config_file_params)
      starter_template_config_file_form.project = project
      starter_template_config_file_form.added_by = user
      starter_template_config_file_form.creation_source = UffizziCore::ConfigFile.creation_source.system
      starter_template_config_file_form.save

      starter_template_config_file_form
    end

    def create_containers(project, user, voting_app_config_file)
      starter_template_containers = {
        name: "Voting App (from base images)",
        payload: {
          containers_attributes: containers_attributes(voting_app_config_file),
        }
      }

      starter_template = ActionController::Parameters.new(starter_template_containers)

      starter_template_form = UffizziCore::Api::Cli::V1::Template::CreateForm.new(starter_template)
      starter_template_form.creation_source = UffizziCore::Template.creation_source.system
      starter_template_form.added_by = user
      starter_template_form.project = project
      starter_template_form.save
    end

    def containers_attributes(voting_app_config_file)
      [
        postgres_container_attributes,
        nginx_container_attributes(voting_app_config_file),
        redis_container_attributes,
        example_worker_container_attributes,
        example_result_container_attributes,
        example_vote_container_attributes
      ]
    end

    def postgres_container_attributes
      {
        image: "library/postgres",
        tag: "9.6",
        port: nil,
        public: false,
        memory_limit: 250,
        memory_request: 250,
        receive_incoming_requests: false,
        continuously_deploy: "disabled",
        secret_variables: nil,
        variables: [
          {
            name: "POSTGRES_USER",
            value: "postgres"
          },
          {
            name: "POSTGRES_PASSWORD",
            value: "postgres"
          }
        ],
        repo_attributes: repo_attributes("library/postgres"),
        container_config_files_attributes: []
      }
    end

    def nginx_container_attributes(voting_app_config_file)
      {
        image: "library/nginx",
        tag: "latest",
        port: 8080,
        public: true,
        memory_limit: 125,
        memory_request: 125,
        receive_incoming_requests: true,
        continuously_deploy: "disabled",
        secret_variables: nil,
        variables: nil,
        repo_attributes: repo_attributes("library/nginx"),
        container_config_files_attributes: [{
          config_file_id: voting_app_config_file.id,
          mount_path: "/etc/nginx/conf.d/"
        }]
      }
    end

    def redis_container_attributes
      {
        image: "library/redis",
        tag: "latest",
        port: nil,
        public: false,
        memory_limit: 125,
        memory_request: 125,
        receive_incoming_requests: false,
        continuously_deploy: "disabled",
        secret_variables: nil,
        variables: nil,
        repo_attributes: repo_attributes("library/redis"),
        container_config_files_attributes: []
      }
    end

    def example_worker_container_attributes
      {
        image: "uffizzicloud/example-worker",
        tag: "latest",
        port: nil,
        public: false,
        memory_limit: 250,
        memory_request: 250,
        receive_incoming_requests: false,
        continuously_deploy: "disabled",
        secret_variables: nil,
        variables: nil,
        repo_attributes: repo_attributes("uffizzicloud/example-worker"),
        container_config_files_attributes: []
      }
    end

    def example_result_container_attributes
      {
        image: "uffizzicloud/example-result",
        tag: "latest",
        port: nil,
        public: false,
        memory_limit: 125,
        memory_request: 125,
        receive_incoming_requests: false,
        continuously_deploy: "disabled",
        secret_variables: nil,
        variables: nil,
        repo_attributes: repo_attributes("uffizzicloud/example-result"),
        container_config_files_attributes: []
      }
    end

    def example_vote_container_attributes
      {
        image: "uffizzicloud/example-vote",
        tag: "latest",
        port: nil,
        public: false,
        memory_limit: 250,
        memory_request: 250,
        receive_incoming_requests: false,
        continuously_deploy: "disabled",
        secret_variables: nil,
        variables: nil,
        repo_attributes: repo_attributes( "uffizzicloud/example-vote"),
        container_config_files_attributes: []
      }
    end

    def config_file_attributes
      {
        filename: "vote.conf",
        kind: "config_map",
        payload: "server {
               listen       8080;
               server_name  example.com;
               location / {
                 proxy_pass      http://127.0.0.1:80/;
               }
               location /vote/ {
                 proxy_pass      http://127.0.0.1:8888/;
               }
            }"
      }
    end

    def repo_attributes(image)
      namespace, name = image.split('/')
      {
        namespace: namespace,
        name: name,
        slug: name,
        type: "UffizziCore::Repo::DockerHub",
        description: "",
        is_private: false,
        repository_id: nil,
        branch: "",
        kind: nil
      }
    end
  end
end

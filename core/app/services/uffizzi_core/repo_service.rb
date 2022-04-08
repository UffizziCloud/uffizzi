# frozen_string_literal: true

module UffizziCore::RepoService
  AVAILABLE_KINDS = [
    {
      name: :buildpacks18,
      detect: proc { |**_args| { available: true, args: [] } },
    },
    {
      name: :dockerfile,
      detect: proc { |**args|
        has_dockerfiles = args[:dockerfiles].is_a?(Array) && !args[:dockerfiles].empty?
        multiple_dockerfiles = has_dockerfiles && args[:dockerfiles].length > 1

        {
          available: has_dockerfiles,
          args: multiple_dockerfiles ? { name: :dockerfile, type: :select, options: args[:dockerfiles] } : [],
        }
      },
    },
    {
      name: :dotnet,
      detect: proc { |**args|
        has_app_runtimes = args[:dotnetruntimes].is_a?(Array) && !args[:dotnetruntimes].empty?
        multiple_app_runtimes = has_app_runtimes && args[:dotnetruntimes].length > 1
        has_csproj = args[:csproj].present?

        {
          available: has_app_runtimes || has_csproj,
          args: multiple_app_runtimes ? { name: :dotnetruntimes, type: :select, options: args[:dotnetruntimes] } : [],
        }
      },
    },
    {
      name: :gatsby,
      detect: proc { |**args| { available: args[:gatsbyconfig].present?, args: [] } },
    }, {
      name: :barestatic,
      detect: proc { |**args|
                { available: args[:barestatic].present? && args.filter_map do |k, v|
                               ![:barestatic, :dockerfiles].include?(k) && v.present?
                             end.blank?, args: [] }
              },
    }
  ].freeze

  class << self
    def nodejs_static?(repo)
      repo.gatsby? || repo.barestatic?
    end

    def cnb?(repo)
      repo.buildpacks18? || repo.dotnet? || nodejs_static?(repo)
    end

    def needs_target_port?(repo)
      return false if repo.nil?

      !repo.dockerfile?
    end

    def credential(repo)
      credentials = repo.project.account.credentials

      case repo.type
      when UffizziCore::Repo::Github.name
        credentials.github.first
      when UffizziCore::Repo::GithubContainerRegistry.name
        credentials.github_container_registry.first
      when UffizziCore::Repo::DockerHub.name
        credentials.docker_hub.first
      when UffizziCore::Repo::Azure.name
        credentials.azure.first
      when UffizziCore::Repo::Google.name
        credentials.google.first
      when UffizziCore::Repo::Amazon.name
        credentials.amazon.first
      end
    end

    def image_name(repo)
      "e#{repo.container.deployment_id}r#{repo.id}-#{Digest::SHA256.hexdigest("#{self.class}:#{repo.branch}:
      #{repo.project_id}:#{repo.id}")[0, 10]}"
    end

    def tag(repo)
      repo&.builds&.deployed&.last&.commit || 'latest'
    end

    def image(repo)
      repo_credential = credential(repo)

      "#{repo_credential.registry_url}/#{image_name(repo)}"
    end

    def select_default_from(meta)
      return :gatsby if meta[:gatsby][:available]
      return :dotnet if meta[:dotnet][:available]
      return :barestatic if meta[:barestatic][:available]

      :buildpacks18
    end

    def available_repo_kinds(repository_id:, branch:, credential:)
      detections = {
        dotnetruntimes: [],
        gatsbyconfig: false,
        csproj: false,

        go: false,
        ruby: false,
        node: false,
        python: false,
        java: false,
        php: false,
        barestatic: false,
      }
      contents = fetch_contents(credential, repository_id, branch)
      repo_contents = contents[:repo_contents]
      detections[:dotnetruntimes] = repo_contents.filter_map do |f|
        (f.name =~ /^(.+\.)?runtime\.json/ || f.name == 'runtime.template.json') && f.name
      end
      detections[:csproj] = repo_contents.filter_map do |f|
        f.name =~ /^.+\.csproj/ && f.name
      end
      detections[:go] = has_go_files?(contents)

      [[:ruby, ['Gemfile']],
       [:node, ['package.json']],
       [:python, ['requirements.txt', 'setup.py', 'Pipfile']],
       [:java, ['pom.xml', 'pom.atom', 'pom.clj', 'pom.groovy', 'pom.rb', 'pom.scala', 'pom.yaml', 'pom.yml']],
       [:php, ['composer.json', 'index.php']],
       [:gatsbyconfig, ['gatsby-config.js']],
       [:barestatic, ['index.html', 'index.htm', 'Default.htm']]].each do |lang|
        detections[lang[0]] = repo_contents.filter_map do |f|
          lang[1].include?(f.name)
        end.present?
      end
    end

    def filter_available_repo_kinds
      kinds = AVAILABLE_KINDS.filter_map do |kind|
        detection = kind[:detect].call(detections)

        kind.merge(detection).except(:detect)
      end.map { |kind| [kind[:name], kind.except(:name)] }.to_h

      kinds.merge({ default: select_default_from(kinds) })
    end

    def fetch_contents(credential, repository_id, branch)
      repo_contents = UffizziCore::Github::CredentialService.contents(credential, repository_id, ref: branch)
      return filter_available_repo_kinds if repo_contents.empty?

      if repo_contents.filter_map { |f| f.name == 'Godeps' }.present?
        godeps_contents = UffizziCore::Github::CredentialService.contents(credential, repository_id, path: 'Godeps/', ref: branch)
      end

      if repo_contents.filter_map { |f| f.name == 'vendor' }.present? && godeps_contents.nil?
        govendor_contents = UffizziCore::Github::CredentialService.contents(credential, repository_id, path: 'vendor/', ref: branch)
      end

      {
        repo_contents: repo_contents,
        godeps_contents: godeps_contents,
        govendor_contents: govendor_contents,
      }
    end

    def go(contents)
      contents[:repo_contents].filter_map do |f|
        ['go.mod', 'Gopkg.lock', 'glide.yaml'].include?(f.name)
      end.present? || contents[:godeps_contents]&.filter_map do |f|
                        f.name == 'Godeps.json'
                      end.present? || contents[:govendor_contents]&.filter_map do |f|
                                        f.name == 'vendor.json'
                                      end.present?
    end
  end
end

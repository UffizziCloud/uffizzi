# frozen_string_literal: true

class UffizziCore::BuildService
  class << self
    def create_build!(repo)
      commit_info = prepare_commit_info(repo)
      attributes =  prepare_build_attributes(repo, commit_info)
      build = repo.builds.find_or_create_by(attributes)
      mark_build_as_last(build)

      UffizziCore::Build::CreateCloudBuildJob.perform_async(build.id) if build.status.nil?
    end

    def monitor_build(build)
      cloud_build = cloud_build_client.get_build(id: build.build_id, project_id: Settings.build.project_id)
      build = update_build_status_from_cloud_build(build, cloud_build)

      UffizziCore::Build::MonitorJob.perform_in(5.seconds, build.id) if build.building?
    end

    def create_cloud_build(build)
      repo = build.repo
      credential = UffizziCore::RepoService.credential(repo)
      namespace = credential.registry_url
      image_name = UffizziCore::RepoService.image_name(repo)

      build_steps = prepare_builds_steps(build, namespace, image_name)

      cloud_build_params = {
        steps: build_steps,
        logs_bucket: Settings.build.log_bucket,
        timeout: 45.minutes.to_i,
        images: [
          "#{namespace}/#{image_name}:#{build.commit}",
          "#{namespace}/#{image_name}:latest",
        ],
      }
      cloud_build = cloud_build_client.create_build(parent: nil, project_id: Settings.build.project_id, build: cloud_build_params)

      cloud_build_id = JSON.parse(cloud_build.grpc_op.to_json, object_class: OpenStruct).metadata.build.id

      build.update(
        status: UffizziCore::Build::BUILDING,
        build_id: cloud_build_id,
        log_url: Settings.build.log_bucket,
      )

      UffizziCore::Build::MonitorJob.perform_in(30.seconds, build.id)
    end

    def logs(build)
      storage = Google::Cloud::Storage.new(project_id: Settings.build.project_id)
      bucket = storage.bucket(build.log_url, skip_lookup: true)
      file = bucket.file("log-#{build.build_id}.txt")

      response_logs = []

      remote_log = Down.open(file.signed_url, rewindable: false)
      remote_log.each_chunk do |chunk|
        response_logs << chunk.gsub(/#{build.build_id}|k8s-skaffold|gcr\.io|#{Settings.build.project_id}/, '******')
      end
      remote_log.close

      response_logs = response_logs.map { |log| log.force_encoding(Encoding::UTF_8).split("\n") }
      response_logs.flatten
    end

    private

    def prepare_build_attributes(repo, commit_info)
      attributes = { repo_id: repo.id, repository: repo.name, branch: repo.branch }

      if commit_info.present?
        return attributes.merge(
          commit: commit_info[:commit],
          committer: commit_info[:committer],
          message: commit_info[:message],
        )
      end

      attributes.merge(status: Build::FAILED)
    end

    def prepare_commit_info(repo)
      credential = UffizziCore::RepoService.credential(repo)

      branch = UffizziCore::Github::CredentialService.branch(credential, repo.repository_id, repo.branch)
      UffizziCore::Github::CredentialService.commit(credential, repo.repository_id, branch[:commit][:sha])
    rescue StandardError
      nil
    end

    def mark_build_as_last(build)
      ActiveRecord::Base.transaction do
        build.repo.builds.update_all(deployed: nil)
        build.reload
        build.update!(deployed: true)
      end
    end

    def update_build_status_from_cloud_build(build, cloud_build)
      new_status = case cloud_build.status
                   when :FAILURE then UffizziCore::Build::FAILED
                   when :TIMEOUT then UffizziCore::Build::TIMEOUT
                   when :CANCELLED then UffizziCore::Build::CANCELLED
                   when :SUCCESS then UffizziCore::Build::SUCCESS
                   when :WORKING then UffizziCore::Build::BUILDING
                   else
                     cloud_build.status
      end

      build.update(status: new_status)

      build
    end

    def prepare_builds_steps(build, namespace, image_name)
      repo = build.repo
      credential = repo.project.account.credentials.github.first
      raise UffizziCore::Github::CredentialNotValidError if credential.unauthorized?

      repo_url = UffizziCore::Github::CredentialService.repo_url(credential, repo.repository_id)

      build_steps = [
        git_clone_step(repo.branch, credential.username, credential.password, repo_url),
        git_checkout_step(build.commit),
      ]

      build_steps.push(nodejs_static_step(repo)) if UffizziCore::RepoService.nodejs_static?(repo)
      build_steps.push(cnb_step(repo, namespace, image_name)) if UffizziCore::RepoService.cnb?(repo)
      build_steps.push(dockerfile_step(repo, namespace, image_name)) if repo.dockerfile?
      build_steps.push(docker_tag_step(namespace, image_name, build.commit))

      build_steps
    end

    def git_checkout_step(commit)
      {
        name: 'alpine/git',
        dir: './build',
        args: ['checkout', commit.to_s],
      }
    end

    def git_clone_step(branch, username, access_token, repo_url)
      {
        name: 'alpine/git',
        args: ['clone', '--depth', '50', '--recurse-submodules', '-j8', '--branch', branch.to_s, '--single-branch',
               "https://#{username}:#{access_token}@#{repo_url}", 'build'],
      }
    end

    def docker_tag_step(namespace, image_name, commit)
      {
        name: 'gcr.io/cloud-builders/docker',
        args: ['tag', "#{namespace}/#{image_name}:latest", "#{namespace}/#{image_name}:#{commit}"],
      }
    end

    def nodejs_static_step(repo)
      site_root = repo.barestatic? ? '/' : 'public'
      gatsby_static_yaml = { staticfile: { nginx: { root: site_root } } }.deep_stringify_keys.to_yaml

      {
        name: 'bash',
        dir: './build',
        args: ['-c', "[[ ! -f buildpack.yml ]] && (echo \"#{gatsby_static_yaml}\" > buildpack.yml )"],
      }
    end

    def cnb_builder(repo)
      if repo.dotnet?
        'paketobuildpacks/builder:full'
      elsif UffizziCore::RepoService.nodejs_static?(repo)
        "gcr.io/#{Settings.build.project_id}/nodejs-static:bionic"
      else
        'heroku/buildpacks:18'
      end
    end

    def cnb_step(repo, namespace, image_name)
      builder = cnb_builder(repo)

      {
        name: 'gcr.io/k8s-skaffold/pack',
        entrypoint: 'pack',
        dir: './build',
        args: ['build', "--builder=#{builder}", "#{namespace}/#{image_name}:latest"],
      }
    end

    def dockerfile_step(repo, namespace, image_name)
      args_command = build_args_command(repo)
      tag_arg = ['-t', "#{namespace}/#{image_name}:latest"]
      dockerfile_context_path = repo.dockerfile_context_path.present? ? repo.dockerfile_context_path : '.'
      dockerfile_path_arg = ['-f', "#{dockerfile_context_path}/#{repo.dockerfile_path}"]

      command = ['build', dockerfile_context_path, tag_arg, args_command, dockerfile_path_arg]
      command = command.flatten.compact_blank

      {
        name: 'gcr.io/cloud-builders/docker',
        dir: './build',
        args: command,
      }
    end

    def cloud_build_client
      ENV['CLOUD_BUILD_CREDENTIALS'] = Settings.build.service_credential if Settings.build.service_credential.present?

      Google::Cloud::Build.cloud_build
    end

    def build_args_command(repo)
      return '' unless repo.args.present?

      repo.args.map do |arg|
        value = arg['value'].to_s.include?(' ') ? "\"#{arg['value']}\"" : arg['value']

        ['--build-arg', "#{arg['name']}=#{value}"]
      end
    end
  end
end

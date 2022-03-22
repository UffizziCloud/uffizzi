# frozen_string_literal: true

class UffizziCore::ComposeFile::UpdateService
  def initialize(user, project)
    @user = user
    @project = project
  end

  def update(compose_file, params)
    compose_file_form = compose_file.becomes(ComposeFile::UpdateForm)
    compose_file_form.assign_attributes(params)
    credential = compose_file_form.project.account.credentials.github.last
    compose_file_github_form = ComposeFileService.create_compose_file_github_form(compose_file_form, credential)

    if compose_file_github_form.invalid?
      if compose_file_github_form.compose_content_data.present?
        compose_file_form.content = compose_file_github_form.compose_content_data[:content]
      end

      return [compose_file_form, compose_file_github_form.errors]
    end

    compose_file_depedencies = compose_file_github_form.compose_dependencies
    compose_file_form.payload['dependencies'] = ComposeFileService.prepare_compose_file_dependencies(compose_file_depedencies)
    compose_file_form.content = compose_file_github_form.compose_content_data[:content]

    ComposeFileService.persist!(compose_file_form, compose_file_github_form)
  end
end

# frozen_string_literal: true

class UffizziCore::ComposeFile::TemplateService
  def initialize(github_form, project, user)
    @project = project
    @user = user
    @compose_dependencies = github_form.compose_dependencies
    @compose_data = github_form.compose_data
    @compose_repositories = github_form.compose_repositories
  end

  def create_template(compose_file_form)
    compose_file_template_form = build_compose_file_template_form(compose_file_form)
    return compose_file_template_form.errors if compose_file_template_form.invalid?

    template_form = build_template_form(compose_file_form, compose_file_template_form)
    return template_form.errors if template_form.invalid?

    template_form.save

    nil
  end

  private

  def build_compose_file_template_form(compose_file_form)
    credentials = @project.account.credentials
    compose_file_template_form = UffizziCore::Api::Cli::V1::ComposeFile::TemplateForm.new
    compose_file_template_form.compose_data = @compose_data
    compose_file_template_form.source = compose_file_form.source
    compose_file_template_form.credentials = credentials
    compose_file_template_form.project = @project
    compose_file_template_form.user = @user
    compose_file_template_form.compose_dependencies = @compose_dependencies
    compose_file_template_form.compose_repositories = @compose_repositories
    compose_file_template_form.assign_template_attributes!

    compose_file_template_form
  end

  def build_template_form(compose_file_form, compose_file_template_form)
    attributes = compose_file_template_form.template_attributes
    source = compose_file_template_form.source
    template = compose_file_form.template
    template = @project.templates.find_or_initialize_by(name: source) if !template.present?
    template.assign_attributes(attributes)
    template_form = template.becomes(UffizziCore::Api::Cli::V1::Template::CreateForm)
    template_form.project = @project
    template_form.added_by = @user
    template_form.compose_file = compose_file_form
    template_form.creation_source = UffizziCore::Template.creation_source.compose_file

    template_form
  end
end

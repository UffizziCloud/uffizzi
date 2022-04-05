# frozen_string_literal: true

require 'test_helper'

class UffizziCore::UserGeneratorServiceTest < ActiveSupport::TestCase
  test '#generate' do
    email = generate(:email)
    password = generate(:password)
    project_name = generate(:string)

    differences = {
      -> { UffizziCore::User.count } => 1,
      -> { UffizziCore::Account.count } => 1,
      -> { UffizziCore::Membership.count } => 1,
      -> { UffizziCore::Project.count } => 1,
    }

    assert_difference differences do
      UffizziCore::UserGeneratorService.generate(email, password, project_name)
    end
  end

  test '#generate if an email gets by a user' do
    email = nil
    password = generate(:password)
    project_name = generate(:string)

    new_email = generate(:email)

    differences = {
      -> { UffizziCore::User.where(email: new_email).count } => 1,
      -> { UffizziCore::Account.count } => 1,
      -> { UffizziCore::Membership.count } => 1,
      -> { UffizziCore::Project.count } => 1,
    }

    console_mock = mock('console_mock')
    console_mock.stubs(:write)
    console_mock.stubs(:gets).returns(new_email)
    IO.stubs(:console).returns(console_mock)

    assert_difference differences do
      UffizziCore::UserGeneratorService.generate(email, password, project_name)
    end
  end

  test '#generate if an email is empty' do
    email = nil
    password = generate(:password)
    project_name = generate(:string)

    differences = {
      -> { UffizziCore::User.where(email: UffizziCore::UserGeneratorService::DEFAULT_USER_EMAIL).count } => 1,
      -> { UffizziCore::Account.count } => 1,
      -> { UffizziCore::Membership.count } => 1,
      -> { UffizziCore::Project.count } => 1,
    }

    console_mock = mock('console_mock')
    console_mock.stubs(:write)
    console_mock.stubs(:gets).returns('')
    IO.stubs(:console).returns(console_mock)

    assert_difference differences do
      UffizziCore::UserGeneratorService.generate(email, password, project_name)
    end
  end

  test '#generate if a password gets by a user' do
    email = generate(:email)
    password = nil
    project_name = generate(:string)

    new_password = generate(:password)

    differences = {
      -> { UffizziCore::User.count } => 1,
      -> { UffizziCore::Account.count } => 1,
      -> { UffizziCore::Membership.count } => 1,
      -> { UffizziCore::Project.count } => 1,
    }

    console_mock = mock('console_mock')
    console_mock.stubs(:write)
    console_mock.stubs(:getpass).returns(new_password)
    IO.stubs(:console).returns(console_mock)

    assert_difference differences do
      UffizziCore::UserGeneratorService.generate(email, password, project_name)
    end
  end

  test '#generate if a password is empty' do
    email = generate(:email)
    password = nil
    project_name = generate(:string)

    console_mock = mock('console_mock')
    console_mock.stubs(:write)
    console_mock.stubs(:getpass).returns('')
    IO.stubs(:console).returns(console_mock)

    assert_raises SystemExit do
      UffizziCore::UserGeneratorService.generate(email, password, project_name)
    end
  end

  test '#generate if a project name gets by a user' do
    email = generate(:email)
    password = generate(:password)
    project_name = nil

    new_project_name = generate(:string)

    differences = {
      -> { UffizziCore::User.count } => 1,
      -> { UffizziCore::Account.count } => 1,
      -> { UffizziCore::Membership.count } => 1,
      -> { UffizziCore::Project.where(name: new_project_name).count } => 1,
    }

    console_mock = mock('console_mock')
    console_mock.stubs(:write)
    console_mock.stubs(:gets).returns(new_project_name)
    IO.stubs(:console).returns(console_mock)

    assert_difference differences do
      UffizziCore::UserGeneratorService.generate(email, password, project_name)
    end
  end

  test '#generate if a project name is empty' do
    email = generate(:email)
    password = generate(:password)
    project_name = nil

    differences = {
      -> { UffizziCore::User.count } => 1,
      -> { UffizziCore::Account.count } => 1,
      -> { UffizziCore::Membership.count } => 1,
      -> { UffizziCore::Project.where(name: UffizziCore::UserGeneratorService::DEFAULT_PROJECT_NAME).count } => 1,
    }

    console_mock = mock('console_mock')
    console_mock.stubs(:write)
    console_mock.stubs(:gets).returns('')
    IO.stubs(:console).returns(console_mock)

    assert_difference differences do
      UffizziCore::UserGeneratorService.generate(email, password, project_name)
    end
  end
end

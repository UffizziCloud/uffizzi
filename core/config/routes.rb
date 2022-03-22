# frozen_string_literal: true

UffizziCore::Engine.routes.draw do
  mount Rswag::Api::Engine => '/api-docs'
  mount Rswag::Ui::Engine => '/api-docs'

  namespace :api, defaults: { format: :json } do
    namespace :cli do
      namespace :v1 do
        resource :webhooks, only: [] do
          post :docker_hub
          post :github
          post :azure
          post :workos
          post :amazon
          post :google
        end

        resources :projects, only: ['index'], param: :slug do
          scope module: :projects do
            resource :compose_file, only: ['show', 'create', 'destroy']
            resources :deployments, only: ['index', 'show', 'create', 'destroy'] do
              post :deploy_containers, on: :member
              scope module: :deployments do
                resources :activity_items, only: ['index']
              end
            end
          end
        end
        resource :session, only: ['create', 'destroy']

        resource :account, only: [] do
          scope module: :account do
            resources :credentials, only: ['create']
          end
        end
      end
    end
  end
end

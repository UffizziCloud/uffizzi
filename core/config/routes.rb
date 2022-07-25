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
          post :amazon
          post :google
        end

        resources :projects, only: ['index', 'show', 'create', 'destroy'], param: :slug do
          scope module: :projects do
            resource :compose_file, only: ['show', 'create', 'destroy']
            resources :deployments, only: ['index', 'show', 'create', 'destroy', 'update'] do
              post :deploy_containers, on: :member
              scope module: :deployments do
                resources :activity_items, only: ['index']
                resources :events, only: ['index']
                resources :containers, only: ['index'], param: :name do
                  scope module: :containers do
                    resources :logs, only: ['index']
                    resources :builds, only: [] do
                      collection do
                        get :logs
                      end
                    end
                  end
                end
              end
            end
            resources :secrets, only: ['index', 'destroy'] do
              collection do
                post :bulk_create
              end
            end
          end
        end
        resource :session, only: ['create', 'destroy']

        resource :account, only: [] do
          scope module: :account do
            resources :credentials, only: ['index', 'create', 'update', 'destroy'], param: :type do
              member do
                get :check_credential
              end
            end
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

UffizziCore::Engine.routes.draw do
  mount Rswag::Api::Engine => '/api-docs'
  mount Rswag::Ui::Engine => '/api-docs'

  namespace :api, defaults: { format: :json } do
    namespace :cli do
      namespace :v1 do
        resources :projects, only: ['index', 'show', 'destroy'], param: :slug do
          scope module: :projects do
            resource :compose_file, only: ['show', 'create', 'destroy']
            resources :deployments, only: ['index', 'show', 'create', 'destroy', 'update'] do
              post :deploy_containers, on: :member
              scope module: :deployments do
                resources :activity_items, only: ['index']
                resources :events, only: ['index']
                resources :containers, only: ['index'], param: :name do
                  get :k8s_container_description
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

        namespace :ci do
          resource :session, only: ['create']
        end

        resources :accounts, only: [] do
          scope module: :accounts do
            resources :projects, only: ['create']
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

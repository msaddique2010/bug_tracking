Rails.application.routes.draw do
  root "projects#index"
  resources :projects do
    resources :bugs do
      member do
        patch :assign
        patch :resolve
      end
    end
  end
  devise_for :users

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      post 'login', to: 'sessions#create'
      delete 'logout', to: 'sessions#destroy'
      resources :projects, only: [:index, :show, :create, :update, :destroy] do
        resources :bugs, only: [:index, :show, :create, :update, :destroy] do
          member do
            patch :assign
            patch :resolve
          end
        end
      end
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end

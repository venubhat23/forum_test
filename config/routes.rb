Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  namespace :super_admin do
    get "dashboard", to: "dashboard#show"
    resources :forums, only: [ :index, :new, :create, :show ] do
      member do
        patch :suspend
        patch :activate
      end
    end
  end

  scope "/f/:forum_slug", as: :forum do
    root to: "forums/dashboard#show"
    get "dashboard", to: "forums/dashboard#show"
    resources :chapters, controller: "forums/chapters", only: [ :index, :new, :create, :show ]
  end

  # Role-based dispatcher: sends signed-in users to their home area.
  get "dashboard", to: "home#dashboard"

  # Defines the root path route ("/")
  root "home#dashboard"
end

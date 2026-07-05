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
        patch :update_plan
      end
    end
  end

  scope "/f/:forum_slug", as: :forum do
    root to: "forums/dashboard#show"
    get "dashboard", to: "forums/dashboard#show"
    resources :chapters, controller: "forums/chapters", only: [ :index, :new, :create, :show ] do
      resources :members, controller: "forums/members", only: [ :index, :new, :create ]
      resources :guests, controller: "forums/guests", only: [ :index, :new, :create ]
      resources :committee_members, controller: "forums/committee_members", only: [ :index, :new, :create ]
      resources :fee_payments, controller: "forums/fee_payments", only: [ :index, :new, :create ] do
        member do
          patch :mark_paid
        end
      end
      resources :attendances, controller: "forums/attendances", only: [ :index, :new, :create ]
      resources :referrals, controller: "forums/referrals", only: [ :index, :new, :create, :show ] do
        resources :thanksgiving_slips, controller: "forums/thanksgiving_slips", only: [ :new, :create ]
      end
    end
    resource :subscription, controller: "forums/subscriptions", only: [ :show ]
  end

  # Role-based dispatcher: sends signed-in users to their home area.
  get "dashboard", to: "home#dashboard"

  # Defines the root path route ("/")
  root "home#dashboard"
end

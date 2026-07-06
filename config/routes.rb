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
    get "analytics", to: "analytics#show"
    get "roles", to: "roles#index"
    resources :forums, only: [ :index, :new, :create, :show, :edit, :update, :destroy ] do
      member do
        patch :suspend
        patch :activate
        patch :update_plan
        post :impersonate
        post :reset_admin_password
        post :force_logout_admin
      end
    end
    resources :plans, except: [ :destroy, :show ] do
      member do
        patch :archive
        patch :activate
      end
    end
    resources :subscriptions, only: [ :index ] do
      member do
        patch :extend_trial
        patch :change_renewal_date
      end
    end
    resources :coupons, except: [ :destroy, :show ] do
      member do
        patch :archive
        patch :activate
      end
    end
    resources :invoices, only: [ :index, :new, :create, :show ] do
      member do
        patch :mark_paid
        patch :void
      end
    end
    resources :payments, only: [ :index ]
    resource :billing, only: [ :edit, :update ], controller: "billing"
    resources :users do
      member do
        patch :suspend
        patch :unsuspend
        post :reset_password
        post :force_logout
      end
    end
    resources :forum_requests, only: [ :index, :show ] do
      member do
        patch :approve
        patch :reject
      end
    end
    resources :announcements do
      member do
        patch :publish
      end
    end
    resources :reports, only: [ :index ] do
      collection do
        get :forums
        get :users
        get :invoices_payments
        get :attendance
        get :referrals_business
      end
    end
    resources :support_tickets, only: [ :index, :show ] do
      member do
        post :reply
        patch :change_status
      end
    end
  end

  resource :impersonation, only: [ :destroy ]

  resources :forum_requests, only: [ :new, :create ]

  scope "/f/:forum_slug", as: :forum do
    root to: "forums/dashboard#show"
    get "dashboard", to: "forums/dashboard#show"
    resources :chapters, controller: "forums/chapters", only: [ :index, :new, :create, :show, :edit, :update, :destroy ] do
      member do
        patch :activate
        patch :assign_admin
      end

      resources :members, controller: "forums/members", only: [ :index, :new, :create, :show, :edit, :update ] do
        collection do
          get :import
          post :bulk_import
        end
        member do
          patch :suspend
          patch :activate
          post :reset_password
          post :force_logout
          patch :renew
          get :print
        end
      end
      resources :guests, controller: "forums/guests", only: [ :index, :new, :create, :show, :edit, :update, :destroy ] do
        member do
          patch :convert_to_member
        end
      end
      resources :committee_members, controller: "forums/committee_members", only: [ :index, :new, :create, :show, :edit, :update, :destroy ]
      resources :fee_payments, controller: "forums/fee_payments", only: [ :index, :new, :create ] do
        member do
          patch :mark_paid
        end
      end
      resources :meetings, controller: "forums/meetings", only: [ :index, :new, :create, :show, :edit, :update, :destroy ]
      resources :weekly_presentations, controller: "forums/weekly_presentations", only: [ :index, :new, :create, :show, :edit, :update, :destroy ]
      resources :attendances, controller: "forums/attendances", only: [ :index, :new, :create ]
      resources :referrals, controller: "forums/referrals", only: [ :index, :new, :create, :show ] do
        resources :thanksgiving_slips, controller: "forums/thanksgiving_slips", only: [ :new, :create ]
      end
    end
    resource :subscription, controller: "forums/subscriptions", only: [ :show ]
    resources :support_tickets, controller: "forums/support_tickets", only: [ :index, :new, :create, :show ] do
      member do
        post :reply
      end
    end
    resources :business_categories, controller: "forums/business_categories", except: [ :show ]
    resources :one_to_one_meetings, controller: "forums/one_to_one_meetings", only: [ :index, :new, :create, :show, :destroy ] do
      member do
        patch :accept
        patch :reject
        patch :complete
      end
    end
    resources :office_darshans, controller: "forums/office_darshans", except: [ :edit, :update ]
  end

  # Role-based dispatcher: sends signed-in users to their home area.
  get "dashboard", to: "home#dashboard"

  # Defines the root path route ("/")
  root "home#dashboard"
end

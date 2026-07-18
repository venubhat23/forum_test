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
        get :tree
        patch :suspend
        patch :activate
        patch :update_plan
        post :impersonate
        post :reset_admin_password
        post :force_logout_admin
        delete :destroy_permanently
      end
      collection do
        delete :bulk_destroy_permanently
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

  get "invoices/:token", to: "public_invoices#show", as: :public_invoice

  scope "/:forum_slug", as: :forum do
    root to: "forums/gateway#show"
    get "dashboard", to: "forums/dashboard#show"
    get "members", to: "forums/members#all"
    get "apply", to: "membership_applications#new"
    post "apply", to: "membership_applications#create"
    resources :membership_applications, controller: "forums/membership_applications", only: [ :index, :show ] do
      member do
        patch :approve
        patch :reject
      end
    end
    resources :membership_plans, controller: "forums/membership_plans", except: [ :show ]
    get "finance", to: "forums/finance#show"
    resources :expenses, controller: "forums/expenses", except: [ :show ]
    resources :documents, controller: "forums/documents", except: [ :show, :edit, :update ]
    resources :announcements, controller: "forums/announcements", only: [ :index, :new, :create, :destroy ]
    resources :notifications, controller: "forums/notifications", only: [ :index ] do
      member do
        patch :mark_read
      end
      collection do
        patch :mark_all_read
      end
    end
    resources :chapters, controller: "forums/chapters", only: [ :index, :new, :create, :show, :edit, :update, :destroy ] do
      member do
        patch :activate
        patch :assign_admin
      end

      resources :members, controller: "forums/members", only: [ :index, :new, :create, :show, :edit, :update ] do
        collection do
          get :import
          post :bulk_import
          post :invite_to_event
        end
        member do
          patch :suspend
          patch :activate
          post :reset_password
          post :force_logout
          patch :renew
          patch :update_role
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
          get :print
        end
      end
      resources :meetings, controller: "forums/meetings", only: [ :index, :new, :create, :show, :edit, :update, :destroy ] do
        member do
          post :remind
          get :attendance
          post :record_attendance
        end
      end
      resources :meeting_schedules, controller: "forums/meeting_schedules", only: [ :index, :new, :create, :show, :destroy ]
      resources :weekly_presentations, controller: "forums/weekly_presentations", only: [ :index, :new, :create, :show, :edit, :update, :destroy ]
      resources :attendances, controller: "forums/attendances", only: [ :index, :new, :create ]
      resources :referrals, controller: "forums/referrals", only: [ :index, :new, :create, :show ] do
        member do
          patch :accept
          patch :reject
        end
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
    resources :leads, controller: "forums/leads" do
      member do
        patch :accept
        patch :release
        patch :advance
        get :new_thanksgiving
        patch :give_thanksgiving
      end
    end
    resources :events, controller: "forums/events" do
      member do
        post :remind
        get :attendance
        post :record_attendance
      end
      resources :registrations, controller: "forums/event_registrations", only: [ :index, :create, :destroy ]
    end
    get "calendar", to: "forums/calendar#show"
    get "scorecard", to: "forums/scorecard#show"
    get "analytics", to: "forums/analytics#show"
    resources :roles, controller: "forums/roles", only: [ :index ]
    resource :settings, controller: "forums/settings", only: [ :edit, :update ]
    resource :profile, controller: "forums/profiles", only: [ :edit, :update ] do
      post :force_logout_others
    end
    get "help", to: "forums/help#show"
    resources :reports, controller: "forums/reports", only: [ :index ] do
      collection do
        get :members
        get :guests
        get :attendance
        get :referrals
        get :business_generated
        get :chapters
        get :meetings
        get :events
        get :renewals
      end
    end
  end

  # Role-based dispatcher: sends signed-in users to their home area.
  get "dashboard", to: "home#dashboard"
  get "awaiting_forum", to: "home#awaiting_forum"

  # Defines the root path route ("/")
  root "home#dashboard"
end

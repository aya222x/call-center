Rails.application.routes.draw do
  # Letter Opener Web (development only)
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Authentication routes
  get "/login", to: "sessions#new", as: :login
  resource :session, only: [ :create, :destroy ] do
    post :refresh, on: :collection
  end

  # Password reset routes
  namespace :password do
    get :forgot, to: "reset#new"
    post :forgot, to: "reset#forgot"
    get :reset, to: "reset#show"
    put :reset, to: "reset#update"
  end

  # Invitation routes (public)
  get "/invitations/:token", to: "invitations#show", as: :accept_invitation
  post "/invitations/:token/accept", to: "invitations#accept"

  # Profile routes (authenticated users)
  resource :profile, only: [ :show, :edit, :update ]

  # Admin routes (super_admin only)
  namespace :admin do
    resources :users do
      member do
        post :resend_invitation
      end
    end
    resources :audit_logs, only: [ :index ]
    get :console, to: "console#index"
  end

  # Dashboard (authenticated users)
  get :dashboard, to: "dashboard#index"

  # Root path - smart redirect based on authentication
  root to: "home#index"

  # Example Inertia route (can be removed later)
  get "inertia-example", to: "inertia_example#index"
end

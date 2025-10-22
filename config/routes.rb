Rails.application.routes.draw do
   resources :posts do
    collection do
      post :import              # /posts/import  -> carica CSV
      get  :export              # /posts/export  -> tutti (CSV/JSON)
    end
    member do
      get :export               # /posts/:id/export -> uno (CSV/JSON)
    end
  end
  resource :session
  resources :passwords, param: :token
# config/routes.rb
constraints AuthenticatedConstraint.new do
  root "dashboard#home", as: :authenticated_root
end
  root "pages#home", as: :unauthenticated_root

  get "dashboard/home"
  get "dashboard/superadmin"
  get "pages/home"
  get "posturacorretta", to: "pages#posturacorretta"
  get "pages/flowpulse", to: "pages#flowpulse"
  get "pages/about"
  get "pages/contact"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "posts#index"
end

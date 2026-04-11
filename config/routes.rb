Rails.application.routes.draw do
  devise_for :users, skip: [ :registrations, :passwords ]

  resources :ingredients

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  resources :users, constraints: { id: /\d+/ }
  resource :profile, only: [ :show, :edit, :update ]
  resources :restrictions

  root "home#index"
end

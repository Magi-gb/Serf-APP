Rails.application.routes.draw do
  get "restriccions/index"
  get "restriccions/show"
  get "restriccions/new"
  get "restriccions/edit"
  get "restriccion/index"
  get "restriccion/show"
  get "restriccion/new"
  get "restriccion/edit"
  devise_for :users, skip: [ :registrations, :passwords ]

  resources :ingredients
  resources :restriccions

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  resources :users, constraints: { id: /\d+/ }
  resource :profile, only: [ :show, :edit, :update ]

  root "home#index"
end

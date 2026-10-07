Rails.application.routes.draw do
  resource :session, only: %i[ new create destroy ]
  resource :dashboard, only: :show
  resources :tickets, only: %i[ new create show update ] do
    resources :comments, only: :create
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboards#show"
end

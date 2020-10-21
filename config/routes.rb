Rails.application.routes.draw do
  mount API::Base, at: "/"
  scope "(:locale)", locale: /en|vi/ do
    root "static_pages#home"

    get "/home", to: "static_pages#home"
    get "/about", to: "static_pages#about"
    get "/contact", to: "static_pages#contact"
    get "/help", to: "static_pages#help"
    get "/signup", to: "users#new"
    post "/signup", to: "users#create"
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"
    get "users/:id/following", to: "followings#index", as: :following
    get "users/:id/followers", to: "followers#index", as: :followers
    resources :users
    resources :account_activations, only: :edit
    resources :password_resets, except: %i(show index destroy)
    resources :microposts, only: %i(create destroy)
    resources :relationships, only: %i(create destroy)
  end
end

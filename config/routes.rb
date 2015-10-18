require 'api_constraints'

Rails.application.routes.draw do
  get 'cart/create'

  get 'cart/edit'

  get 'cart/destroy'

  devise_for :members
  # Api definition
  namespace :api, defaults: { format: :json }, constraints: { }, path: '/api' do
    # We are going to list our resources here
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      # We are going to list our resources here
      resources :members, :only => [:show, :create, :destroy] do
        resources :addresses
        resources :cart
      end
      resources :sessions, :only => [:create, :destroy]
      resources :books, :only => [:index, :show, :create]
      get '/myprofile' => 'members#profile_detail'
      put '/members' => 'members#update'
      post '/members/stocks' => 'members#create_stock'
    end
  end
end

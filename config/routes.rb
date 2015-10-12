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
        resources :carts
      end
      resources :sessions, :only => [:create, :destroy]
      get '/myprofile' => 'members#profile_detail'
      put '/members' => 'members#update'
    end
  end
end

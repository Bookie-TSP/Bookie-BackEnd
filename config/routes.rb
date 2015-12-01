require 'api_constraints'

Rails.application.routes.draw do

  devise_for :members
  # Api definition
  namespace :api, defaults: { format: :json }, constraints: { }, path: '/api' do
    # We are going to list our resources here
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      # We are going to list our resources here
      resources :members, :only => [:show, :create, :destroy] do
        resources :addresses
      end
      resources :sessions, :only => [:create, :destroy]
      resources :books, :only => [:index, :show, :create]
      get '/myprofile' => 'members#profile_detail'
      get '/mystocks' => 'members#get_my_stock'
      get '/myorders' => 'members#get_my_order'
      get '/mysupplyorders' => 'members#get_my_supply_order'
      put '/members' => 'members#update'
      post '/members/stocks' => 'members#create_stock'
      post '/members/cart/add' => 'members#add_stock_to_cart'
      post '/members/cart/remove' => 'members#remove_stock_from_cart'
      get '/members/cart/show' => 'members#get_stock_in_cart'
      post '/members/edit_address' => 'members#edit_address'
      post '/members/cart/checkout' => 'members#checkout'
      post '/members/line_stocks/quantity' => 'members#change_quantity_of_line_stock'
      post '/members/orders/accept' => 'members#accept_stock_in_order'
      post '/members/orders/decline' => 'members#decline_stock_in_order'
      post '/members/orders/delivering' => 'members#change_stock_status_delivering'
      post '/members/orders/delivered' => 'members#change_stock_status_delivered'
      post '/members/orders/returning' => 'members#change_stock_status_returning'
      post '/members/orders/returned' => 'members#change_stock_status_returned'
      post '/books/search' => 'books#search'
    end
  end
end

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
      get '/mystocks' => 'stocks#get_my_stock'
      get '/myorders' => 'orders#get_my_order'
      get '/mysupplyorders' => 'orders#get_my_supply_order'
      put '/members' => 'members#update'
      post '/members/stocks' => 'stocks#create'
      post '/members/cart/add' => 'carts#add_stock_to_cart'
      post '/members/cart/remove' => 'carts#remove_stock_from_cart'
      get '/members/cart/show' => 'carts#get_stock_in_cart'
      post '/members/edit_address' => 'addresses#edit_address'
      post '/members/cart/checkout' => 'carts#checkout'
      post '/members/line_stocks/quantity' => 'linestocks#change_quantity_of_line_stock'
      post '/members/orders/accept' => 'orders#accept_stock_in_order'
      post '/members/orders/decline' => 'orders#decline_stock_in_order'
      post '/members/orders/delivering' => 'orders#change_stock_status_delivering'
      post '/members/orders/delivered' => 'orders#change_stock_status_delivered'
      post '/members/orders/returning' => 'orders#change_stock_status_returning'
      post '/members/orders/returned' => 'orders#change_stock_status_returned'
      post '/books/search' => 'books#search'
    end
  end
end

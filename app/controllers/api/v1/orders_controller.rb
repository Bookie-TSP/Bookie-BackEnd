class Api::V1::OrdersController < ApplicationController
	before_action :authenticate_with_token!, only: [:get_my_order, :get_my_supply_order, :accept_stock_in_order, 
																									:decline_stock_in_order, :change_stock_status_delivering,
																									:change_stock_status_delivered, :change_stock_status_returning, :change_stock_status_returned]
	respond_to :json

	def get_my_order
    render json: current_user.to_json(:include => { :orders => { :include => [:address, :stocks => { :methods => :member,:include => { :book => { :only => :title } } }] } }), status: 200
  end

  def get_my_supply_order
    temp_orders = current_user.orders.where(side: 'supplier').all
    respond_with current_user.as_json.merge({ orders: temp_orders.as_json(:include => [:address, :stocks => { :methods => :member, :include => { :book => { :only => :title } } }] )})
  end

  def accept_stock_in_order
    member_order = current_user.orders.find_by_id(accept_and_decline_order_params[:order_id])
    if !member_order
      render json: { errors: 'Order not found' }, status: 422 and return
    end
    if member_order.side != 'supplier'
      render json: { errors: 'Can\'t accept your own order' }, status: 422 and return
    end
    member_stock = member_order.stocks.find_by_id(accept_and_decline_order_params[:stock_id])
    if !member_stock
      render json: { errors: 'Stock not found' }, status: 422 and return
    end
    if member_stock.status == 'pending'
      member_stock.status = 'accepted'
      member_stock.orders.each do |temp_order|
        temp_order.status = 'active'
        temp_order.save
      end
      member_stock.save
      member_order.save
      render json: member_order.to_json(:include => [:stocks, :address]), status: 200 and return
    else
      render json: { errors: 'This stock is not in pending state' }, status: 422 and return
    end
  end

  def decline_stock_in_order
    member_order = current_user.orders.find_by_id(accept_and_decline_order_params[:order_id])
    if !member_order
      render json: { errors: 'Order not found' }, status: 422 and return
    end
    if member_order.side != 'supplier'
      render json: { errors: 'Can\'t decline your own order' }, status: 422 and return
    end
    member_stock = member_order.stocks.find_by_id(accept_and_decline_order_params[:stock_id])
    if !member_stock
      render json: { errors: 'Stock not found' }, status: 422 and return
    end
    if member_stock.status == 'pending'
      member_stock.status = 'declined'
      member_stock.orders.each do |temp_order|
        if temp_order.stocks.count(:conditions => [ 'status = ? or status = ?', 'declined', 'done']) == temp_order.stocks.size
          temp_order.status = 'ended'
          temp_order.save
        end
      end
      member_stock.save
      member_order.save
      render json: member_order.to_json(:include => [:stocks, :address]), status: 200 and return
    else
      render json: { errors: 'This stock is not in pending state' }, status: 422 and return
    end
  end

  def change_stock_status_delivering
    member_order = current_user.orders.find_by_id(accept_and_decline_order_params[:order_id])
    if !member_order
      render json: { errors: 'Order not found' }, status: 422 and return
    end
    if member_order.side != 'supplier'
      render json: { errors: 'Can\'t change your own order to delivering status' }, status: 422 and return
    end
    member_stock = member_order.stocks.find_by_id(accept_and_decline_order_params[:stock_id])
    if !member_stock
      render json: { errors: 'Stock not found' }, status: 422 and return
    end
    if member_stock.status == 'accepted'
      member_stock.status = 'delivering'
      member_stock.save
      member_order.save
      render json: member_order.to_json(:include => [:stocks, :address]), status: 200 and return
    else
      render json: { errors: 'This stock is not in accepted state' }, status: 422 and return
    end
  end

  def change_stock_status_delivered
    member_order = current_user.orders.find_by_id(accept_and_decline_order_params[:order_id])
    if !member_order
      render json: { errors: 'Order not found' }, status: 422 and return
    end
    if member_order.side != 'supplier'
      render json: { errors: 'Can\'t change your own order to delivered status' }, status: 422 and return
    end
    member_stock = member_order.stocks.find_by_id(accept_and_decline_order_params[:stock_id])
    if !member_stock
      render json: { errors: 'Stock not found' }, status: 422 and return
    end
    if member_stock.status == 'delivering'
      member_stock.status = 'delivered'
      if member_stock.type == 'sell'
        member_stock.status = 'done'
      end
      member_stock.orders.each do |temp_order|
        if temp_order.stocks.count(:conditions => [ 'status = ? or status = ?', 'declined', 'done']) == temp_order.stocks.size
          temp_order.status = 'ended'
          temp_order.save
        end
      end
      member_stock.save
      member_order.save
      render json: member_order.to_json(:include => [:stocks, :address]), status: 200 and return
    else
      render json: { errors: 'This stock is not in delivering state' }, status: 422 and return
    end
  end

  def change_stock_status_returning
    member_order = current_user.orders.find_by_id(accept_and_decline_order_params[:order_id])
    if !member_order
      render json: { errors: 'Order not found' }, status: 422 and return
    end
    if member_order.side != 'supplier'
      render json: { errors: 'Can\'t change your own order to returning status' }, status: 422 and return
    end
    member_stock = member_order.stocks.find_by_id(accept_and_decline_order_params[:stock_id])
    if !member_stock
      render json: { errors: 'Stock not found' }, status: 422 and return
    end
    if member_stock.status == 'delivered'
      member_stock.status = 'returning'
      member_stock.save
      member_order.save
      render json: member_order.to_json(:include => [:stocks, :address]), status: 200 and return
    else
      render json: { errors: 'This stock is not in delivered state' }, status: 422 and return
    end
  end

  def change_stock_status_returned
    member_order = current_user.orders.find_by_id(accept_and_decline_order_params[:order_id])
    if !member_order
      render json: { errors: 'Order not found' }, status: 422 and return
    end
    if member_order.side != 'supplier'
      render json: { errors: 'Can\'t change your own order to returned status' }, status: 422 and return
    end
    member_stock = member_order.stocks.find_by_id(accept_and_decline_order_params[:stock_id])
    if !member_stock
      render json: { errors: 'Stock not found' }, status: 422 and return
    end
    if member_stock.status == 'returning' || member_stock.status == 'declined'
      member_stock.status = 'done'
      member_stock.orders.each do |temp_order|
        if temp_order.stocks.count(:conditions => [ 'status = ? or status = ?', 'declined', 'done']) == temp_order.stocks.size
          temp_order.status = 'ended'
          temp_order.save
        end
      end
      member_stock.save
      member_order.save
      render json: member_order.to_json(:include => [:stocks, :address]), status: 200 and return
    else
      render json: { errors: 'This stock is not in returning state' }, status: 422 and return
    end
  end

  private

  	def accept_and_decline_order_params
      params.require(:order).permit(:order_id, :stock_id)
    end
end

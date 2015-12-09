class Api::V1::CartsController < ApplicationController
	before_action :authenticate_with_token!, only: [:add_stock_to_cart, :remove_stock_from_cart, :get_stock_in_cart, :checkout]
	respond_to :json
	
	def add_stock_to_cart
    line_stock = LineStock.find_by_id(cart_params[:line_stock_id])
    if line_stock.nil?
      render json: { errors: 'Stock not found' }, status: 422 and return
    elsif line_stock.member_id == current_user.id
      render json: { errors: 'You can\'t add your own stock to cart' }, status: 422 and return
    end
    stocks = line_stock.stocks
    counter = 0
    stocks.each do |stock|
      if current_user.cart.stocks.find_by_id(stock.id)
        counter += 1
      else
        current_user.cart.stocks << stock
        render json: current_user.cart.stocks.find(stock.id).to_json(:include => :book, :methods => :member) and return
      end
    end
    if ( counter == stocks.size )
      render json: { errors: 'All of this stock(s) is already in your cart' }, status: 422
    end
  end

  def remove_stock_from_cart
    temp_stock = Stock.find_by_id(cart_remove_params[:stock_id])
    if temp_stock.nil?
      render json: { errors: 'Stock not found' }, status: 422
    elsif current_user.cart.stocks.find_by_id(cart_remove_params[:stock_id])
      current_user.cart.stocks.delete(temp_stock)
      render json: current_user.cart.to_json(:include => { :stocks => { :include => :book, :methods => :member }}), status: 200
    else
      render json: { errors: 'This stock is not in this cart' }, status: 422
    end
  end

  def get_stock_in_cart
    render json: current_user.cart.to_json(:include => { :stocks => { :include => :book, :methods => :member }}), status: 200
  end

  def checkout
    ActiveRecord::Base.transaction do
      if current_user.cart.stocks.size == 0
        render json: { errors: 'Your cart is empty' }, status: 422 and return
      end
      target_stocks = current_user.cart.stocks.group_by(&:member_id)
      if !target_stocks
        render json: { errors: 'Something went wrong' }, status: 422 and return
      end
      begin
        temp_date = Date.strptime('30/'+checkout_params[:billing_card_expire_date], "%d/%m/%y")
        if !temp_date
          render json: { errors: 'Invalid expire date' }, status: 422 and return
        end
      rescue ArgumentError
        render json: { errors: 'Invalid expire date' }, status: 422 and return
      end
      if temp_date.past?
        render json: { errors: 'Credit card was expired' }, status: 422 and return
      end
      temp_payment = Payment.new(checkout_params)
      if !temp_payment.save
        render json: { errors: temp_payment.errors }, status: 422 and return
      end
      my_order = current_user.orders.create
      my_order.status = 'pending'
      my_order.side = 'member'
      my_order.address = current_user.addresses.first
      my_order.total_price = 0
      my_order.payment = temp_payment
      temp_payment.order = my_order
      temp_payment.save
      target_stocks.each do |group|
        supplier_user = Member.find(group[0])
        supplier_order = supplier_user.orders.create
        supplier_order.status = 'pending'
        supplier_order.side = 'supplier'
        supplier_order.address = current_user.addresses.first
        supplier_order.total_price = 0
        supplier_order.payment = temp_payment
        group[1].each do |stock|
          stock.status = 'pending'
          my_order.stocks << stock
          my_order.total_price += stock.price
          supplier_order.stocks << stock
          supplier_order.total_price += stock.price
          temp_line_stock = stock.line_stock
          temp_line_stock.stocks.delete(stock)
          temp_line_stock.quantity = temp_line_stock.stocks.size
          temp_line_stock.save
          stock.clear_cart
          stock.save
          my_order.save
          supplier_order.save
        end
      end
      render json: my_order.to_json(:include => [:stocks, :address, :payment]), status: 200
    end
  end

  private

  	def cart_params
    	params.require(:line_stock).permit(:line_stock_id)
	  end
	    
	  def cart_remove_params
	    params.require(:stock).permit(:stock_id)
	  end
	  
	  def checkout_params
	    params.require(:payment).permit(:billing_name, :billing_type, :billing_card_number, :billing_card_expire_date, :billing_card_security_number)
	  end
end

class Api::V1::MembersController < ApplicationController
  before_action :authenticate_with_token!, only: [:update, :destroy, :profile_detail, :create_stock, :add_stock_to_cart, 
                                                  :get_stock_in_cart, :edit_address, :get_my_stock, :checkout,
                                                  :get_my_order, :change_quantity_of_line_stock, :accept_stock_in_order,
                                                  :decline_stock_in_order, :get_my_supply_order]
	respond_to :json

  def profile_detail
    respond_with current_user.to_json(:include => :addresses), except: [:auth_token, :created_at, :updated_at]
  end

  def edit_address
    member_password = edit_address_params[:password]
    if current_user.valid_password? member_password
      params[:address].delete :password
      temp_address = current_user.addresses.first
      if temp_address.update(edit_address_params)
        render json:  current_user.to_json(:include => :addresses), status: 200, location: [:api, current_user]
      else
        render json: { errors: temp_address.errors }, status: 422
      end
    else
      render json: { errors: 'Wrong password' }, status: 422
    end
  end

  def show
    respond_with Member.find(params[:id]).to_json(:include => :addresses), except: [:auth_token]
  end

  def create
    ActiveRecord::Base.transaction do
      member = Member.new(member_params)
      if member.save
        cart_temp = member.create_cart
        address_temp = member.addresses.build(address_params)
        if address_temp.save
          render json: member.to_json(:include => :addresses), status: 201, location: [:api, member]
        else
          render json: { errors: address_temp.errors }, status: 422
        end
      else
        render json: { errors: member.errors }, status: 422
      end
    end
  end

  def update
    member = current_user
    member_password = member_update_params[:password]
    if member.valid_password? member_password
      if member.update(member_params)
        render json:  member.to_json(:except => :auth_token), status: 200, location: [:api, member]
      else
        render json: { errors: member.errors }, status: 422
      end
    else
      render json: { errors: 'Wrong password' }, status: 422
    end
  end

  def create_stock
    temp_book = Book.find_by_id(stock_params[:book_id])
    ActiveRecord::Base.transaction do
      if temp_book.nil?
        render json: { errors: 'Book not found' }, status: 422
      else
        if ( !(stock_params[:type] == 'sell') && !(stock_params[:type] == 'lend') )
          render json: { errors: 'Wrong type' }, status: 422 and return
        end
        user_line_stocks = current_user.line_stocks
        temp_stock_for_check = Stock.new(stock_params.except(:quantity))
        temp_stock_for_check.member_id = current_user.id
        user_line_stocks.each do |temp_line_stock|
          if eql_attributes?(temp_line_stock, temp_stock_for_check)
            stock_creation(temp_book, temp_line_stock, stock_params)
            return
          end
        end
        line_stock_temp = current_user.line_stocks.build
        line_stock_temp.type = stock_params[:type]
        line_stock_temp.price = stock_params[:price]
        line_stock_temp.condition = stock_params[:condition]
        line_stock_temp.duration = stock_params[:duration]
        line_stock_temp.description = stock_params[:description]
        line_stock_temp.terms = stock_params[:terms]
        line_stock_temp.book = temp_book
        stock_creation(temp_book, line_stock_temp, stock_params)
        return
      end
    end
  end

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

  def get_my_stock
    render json: current_user.to_json(:include => [:addresses, :line_stocks => { :include => [ :book, :stocks => { :methods => :member, :only => :id } ] }]), status: 201, location: [:api, current_user]
  end

  def destroy
    current_user.destroy
    head 204
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
      temp_payment = Payment.new(checkout_params)
      my_order = current_user.orders.create
      my_order.status = 'pending'
      my_order.side = 'member'
      my_order.address = current_user.addresses.first
      my_order.total_price = 0
      my_order.payment = temp_payment
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

  def get_my_order
    render json: current_user.to_json(:include => { :orders => { :include => [:address, :stocks => { :methods => :member , :include => { :book => { :only => :title } } }] } }), status: 200
  end

  def get_my_supply_order
    temp_orders = current_user.orders.where(side: 'supplier').all
    respond_with current_user.as_json.merge({ orders: temp_orders.as_json(:include => [:address, :stocks => { :methods => :member , :include => { :book => { :only => :title } } }] )})
  end

  def change_quantity_of_line_stock
    line_stock = LineStock.find_by_id(line_stock_params[:line_stock_id])
    if line_stock.nil?
        render json: { errors: 'Line stock not found' }, status: 422 and return
    end
    quantity = line_stock_params[:quantity]
    temp_book = line_stock.book
    new_stock = Stock.new(
                          member_id: line_stock.member_id, status: "stock", 
                          type: line_stock.type, price: line_stock.price, 
                          condition: line_stock.condition, duration: line_stock.duration,
                          terms: line_stock.terms,description: line_stock.description)
    if quantity == 0
      line_stock.stocks.destroy_all
      line_stock.quantity = 0
      line_stock.save
      render json: current_user.to_json(:include => [:addresses, :line_stocks => { :include => [ :book, :stocks => { :methods => :member, :only => :id } ] }]), status: 201, location: [:api, current_user] and return
    elsif quantity == line_stock.stocks.size
      render json: current_user.to_json(:include => [:addresses, :line_stocks => { :include => [ :book, :stocks => { :methods => :member, :only => :id } ] }]), status: 201, location: [:api, current_user] and return
    elsif quantity > line_stock.stocks.size
      (line_stock.quantity..quantity-1).each do |i|
        temp_new_stock = line_stock.stocks.build(new_stock.attributes)
        temp_new_stock.book = temp_book
        line_stock.save
        logger.debug("I = " + i.to_s)
      end
      line_stock.save
      logger.debug("line stock quantity = " + line_stock.stocks.size.to_s)
    elsif line_stock.stocks.size > quantity
      number_of_item_to_be_deleted = line_stock.stocks.size - quantity
      array_of_id = []
      (1..number_of_item_to_be_deleted).each do |i|
        array_of_id << line_stock.stocks.last.id
        line_stock.stocks.last.destroy
        line_stock.stocks.reload
      end
      logger.debug("Array" + array_of_id.to_s)
    end
    line_stock.quantity = line_stock.stocks.size
    line_stock.save
    render json: current_user.to_json(:include => [:addresses, :line_stocks => { :include => [ :book, :stocks => { :methods => :member } ] }]), status: 200, location: [:api, current_user]
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
      member_stock.save
      member_order.save
      render json: member_order.to_json(:include => [:stocks, :address]), status: 200 and return
    elsif 
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
      member_stock.save
      member_order.save
      render json: member_order.to_json(:include => [:stocks, :address]), status: 200 and return
    elsif 
      render json: { errors: 'This stock is not in pending state' }, status: 422 and return
    end
  end

  private

    def member_params
      params.require(:member).require(:password_confirmation)
      params.require(:member).permit(:email, :password, :password_confirmation, :first_name, :last_name, :phone_number, :identification_number, :gender, :birth_date)
    end

    def edit_address_params
      params.require(:address).permit(:password, :first_name, :last_name, :latitude, :longitude, :information)
    end

    def address_params
      params.require(:address).permit(:first_name, :last_name, :latitude, :longitude, :information)
    end

    def member_update_params
      params.require(:member).require(:password)
      params.require(:member).permit(:email, :password, :first_name, :last_name, :phone_number, :identification_number, :gender, :birth_date)
    end

    def stock_params
      params.require(:stock).permit(:book_id, :status, :type, :price, :condition, :duration, :terms, :quantity, :description)
    end
    
    def line_stock_params
      params.require(:line_stock).permit(:line_stock_id, :quantity)
    end

    def cart_params
      params.require(:line_stock).permit(:line_stock_id)
    end

    def checkout_params
      params.require(:payment).permit(:billing_name, :billing_type, :billing_card_number, :billing_card_expire_date, :billing_card_security_number)
    end

    def accept_and_decline_order_params
      params.require(:order).permit(:order_id, :stock_id)
    end

    def cart_remove_params
      params.require(:stock).permit(:stock_id)
    end

    def eql_attributes?(old_stock, new_stock)
      meta = [:id, :created_at, :updated_at, :line_stock_id, :quantity, :status]
      old_stock = old_stock.attributes.symbolize_keys.except(*meta)
      new_stock = new_stock.attributes.symbolize_keys.except(*meta)
      logger.debug("Old =  " + old_stock.to_s)
      logger.debug("New = " + new_stock.to_s)
      logger.debug("Equals ? " + (old_stock == new_stock).to_s)
      old_stock == new_stock
    end

    def stock_creation(book, line_stock_being_operated, params)
      stock_quantity = params[:quantity]
      (1..stock_quantity).each do |i|
        stock_temp = line_stock_being_operated.stocks.build(params.except(:quantity))
        stock_temp.member_id = current_user.id
        stock_temp.book = book
      end
      line_stock_being_operated.quantity = line_stock_being_operated.stocks.size
      if line_stock_being_operated.save
        render json: current_user.to_json(:include => [:addresses, :line_stocks => { :include => [ :book, :stocks => { :methods => :member, :only => :id } ] }]), status: 201, location: [:api, current_user]
      else
        if stock_temp.save
          render json: { errors: line_stock_being_operated.errors }, status: 422
        else
          render json: { errors: stock_temp.errors }, status: 422
        end
      end
    end
end

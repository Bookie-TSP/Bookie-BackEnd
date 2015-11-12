class Api::V1::MembersController < ApplicationController
  before_action :authenticate_with_token!, only: [:update, :destroy, :profile_detail, :create_stock, :add_stock_to_cart, :get_stock_in_cart, :edit_address, :get_my_stock]
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
          if eql_attributes?(temp_line_stock.stocks.first, temp_stock_for_check)
            stock_creation(temp_book, temp_line_stock, stock_params)
            return
          end
        end
        line_stock_temp = current_user.line_stocks.build
        line_stock_temp.type = stock_params[:type]
        stock_creation(temp_book, line_stock_temp, stock_params)
        return
      end
    end
  end

  def add_stock_to_cart
    line_stock = LineStock.find_by_id(cart_params[:line_stock_id])
    stocks = line_stock.stocks
    counter = 0
    stocks each do |stock|
      if line_stock.nil?
        render json: { errors: 'Stock not found' }, status: 422 and return
      elsif current_user.cart.stocks.find_by_id(stock.id)
        counter += 1
      else
        current_user.cart.stocks << stock
        render json: current_user.cart.to_json(:include => { :stocks => { :include => :book, :methods => :member }}), status: 200
      end
    end
    if ( counter == stocks.size )
      render json: { errors: 'All of this stock(s) is already in your cart' }, status: 422
    end
  end

  def remove_stock_from_cart
    temp_stock = Stock.find_by_id(cart_params[:stock_id])
    if temp_stock.nil?
      render json: { errors: 'Stock not found' }, status: 422
    elsif current_user.cart.stocks.find_by_id(cart_params[:stock_id])
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
    render json: current_user.to_json(:include => {:stocks => { :include => :book, :methods => :member }}), status: 200
  end

  def destroy
    current_user.destroy
    head 204
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

    def cart_params
      params.require(:line_stock).permit(:line_stock_id)
    end

    def eql_attributes?(old_stock, new_stock)
      meta = [:id, :created_at, :updated_at, :line_stock_id]
      old_stock = old_stock.attributes.symbolize_keys.except(*meta)
      new_stock = new_stock.attributes.symbolize_keys.except(*meta)
      old_stock == new_stock
    end

    def stock_creation(book, line_stock_being_operated, params)
      stock_quantity = params[:quantity]
      logger.debug("Quantity : " + stock_quantity.to_s)
      (1..stock_quantity).each do |i|
        stock_temp = line_stock_being_operated.stocks.build(params.except(:quantity))
        stock_temp.member_id = current_user.id
        stock_temp.book = book
      end
      line_stock_being_operated.quantity = line_stock_being_operated.stocks.size
      if line_stock_being_operated.save
        render json: current_user.to_json(:include => [:addresses, :line_stocks]), status: 201, location: [:api, current_user]
      else
        if stock_temp.save
          render json: { errors: line_stock_being_operated.errors }, status: 422
        else
          render json: { errors: stock_temp.errors }, status: 422
        end
      end
    end
end

class Api::V1::StocksController < ApplicationController
	before_action :authenticate_with_token!, only: [:create, :get_my_stock]
	respond_to :json
	
	def create
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

	def get_my_stock
    render json: current_user.to_json(:include => [:addresses, :line_stocks => { :include => [ :book, :stocks => { :methods => :member, :only => :id } ] }]), status: 201, location: [:api, current_user]
  end

  private

    def stock_params
      params.require(:stock).permit(:book_id, :status, :type, :price, :condition, :duration, :terms, :quantity, :description)
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
        if !stock_temp.save
          render json: { errors: stock_temp.errors }, status: 422 and return
        end
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
class Api::V1::LinestocksController < ApplicationController
	before_action :authenticate_with_token!, only: :change_quantity_of_line_stock
	respond_to :json

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

  private

    def line_stock_params
      params.require(:line_stock).permit(:line_stock_id, :quantity)
    end
end

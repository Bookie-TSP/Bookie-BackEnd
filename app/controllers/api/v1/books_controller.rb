class Api::V1::BooksController < ApplicationController
	before_action :authenticate_with_token!, only: :create
	respond_to :json

	def index
		respond_with Book.all
	end

	def show
		temp_stocks = Stock.where(book_id: params[:id]).all
		line_stock_ids = []
		temp_stocks.each do |stock|
			line_stock_ids << stock.line_stock_id
		end
		line_stock_ids = line_stock_ids.uniq
		line_stocks = LineStock.find(line_stock_ids)
		# render json: line_stocks.to_json(:include => {:stocks => {:methods => :member}}), status: 200
		# respond_with Book.find(params[:id]).to_json(:include => {:stocks => {:methods => :member}} )
		respond_with Book.find(params[:id]).as_json.merge({ line_stocks: line_stocks.as_json(:include => {:stocks => {:methods => :member}})})
	end

	def create
		book = Book.new(book_params)
		if book.save
			render json: book, status: 201, location: [:api, book]
		else
			render json: { errors: book.errors }, status: 422
		end
	end

	private

	  def book_params
      params.require(:book).permit(:title, :ISBN10, :ISBN13, :description, :publish_date, :cover_image_url, :language, :pages, :publisher, :authors => [])
    end
end
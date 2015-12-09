class Api::V1::BooksController < ApplicationController
	before_action :authenticate_with_token!, only: :create
	respond_to :json

	def index
		respond_with Book.all.as_json(:methods => :lowest_price)
	end

	def search
		if !search_params[:title].nil?
		books = Book.search_title(search_params[:title])
		elsif !search_params[:ISBN].nil?
			if search_params[:ISBN].length == 10
				books = Book.search_ISBN10(search_params[:ISBN])
			elsif search_params[:ISBN].length == 13
				books = Book.search_ISBN13(search_params[:ISBN])
			else
				render json: { errors: 'invalid ISBN' }, status: 422
			end
		elsif !search_params[:publisher].nil?
			books = Book.search_publisher(search_params[:publisher])
		elsif !search_params[:author].nil?
			books = Book.search_author(search_params[:author])
		end
		render json: books.as_json(:methods => :lowest_price), status: 200
	end

	def show
		temp_stocks = Stock.where(book_id: params[:id]).all
		if !temp_stocks
			render json: { errors: 'Book not found' }, status: 422
		end
		line_stock_ids = []
		temp_stocks.each do |stock|
			line_stock_ids << stock.line_stock_id
		end
		line_stock_ids = line_stock_ids.uniq
		line_stocks = LineStock.find_by_id(line_stock_ids)
		if !line_stocks
			line_stocks = []
		end
		respond_with Book.find(params[:id]).as_json.merge( { line_stocks: line_stocks.as_json(:include => {:stocks => {:methods => :member, :only => :id}})})
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

    def search_params
    	params.require(:book).permit(:title, :ISBN, :publisher, :author)
    end
end
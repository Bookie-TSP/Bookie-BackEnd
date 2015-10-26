class Api::V1::BooksController < ApplicationController
	before_action :authenticate_with_token!, only: :create
	respond_to :json

	def index
		respond_with Book.all
	end

	def show
		respond_with Book.find(params[:id]).to_json(:include => :stocks)
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
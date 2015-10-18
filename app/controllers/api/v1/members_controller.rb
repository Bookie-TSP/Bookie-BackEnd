class Api::V1::MembersController < ApplicationController
  before_action :authenticate_with_token!, only: [:update, :destroy, :profile_detail, :create_stock]
	respond_to :json

  def profile_detail
    respond_with current_user.to_json(:include => :addresses), except: [:auth_token, :created_at, :updated_at]
  end

  def show
    respond_with Member.find(params[:id]).to_json(:include => :addresses), except: [:auth_token]
  end

  def create
    ActiveRecord::Base.transaction do
      member = Member.new(member_params)
      if member.save!
        cart_temp = member.create_cart
        address_temp = member.addresses.build(address_params)
        if address_temp.save!
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
    member = current_user
    line_stock_temp = member.line_stocks.build
    line_stock_temp.quantity = stock_params[:quantity]
    line_stock_temp.type = stock_params[:type]
    line_stock_temp.save
    params[:stock].delete :quantity
    (1..line_stock_temp.quantity).each do |i|
    stock_temp = line_stock_temp.stocks.build(stock_params)
    stock_temp.member_id = member.id
    end
    line_stock_temp.save
    render json: member.to_json(:include => :line_stocks), status: 201, location: [:api, member]
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

    def address_params
      params.require(:address).permit(:first_name, :last_name, :latitude, :longitude, :information)
    end

    def member_update_params
      params.require(:member).require(:password)
      params.require(:member).permit(:email, :password, :first_name, :last_name, :phone_number, :identification_number, :gender, :birth_date)
    end

    def stock_params
      params.require(:stock).permit(:book_id, :status, :type, :price, :condition, :duration, :terms, :quantity)
    end
end

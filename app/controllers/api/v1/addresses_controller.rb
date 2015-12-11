class Api::V1::AddressesController < ApplicationController
	before_action :authenticate_with_token!, only: :edit_address
	respond_to :json
	
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

	private

  	def edit_address_params
    	params.require(:address).permit(:password, :first_name, :last_name, :latitude, :longitude, :information)
  	end
end

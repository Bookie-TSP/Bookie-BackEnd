class Api::V1::SessionsController < ApplicationController
	def create
    member_password = params[:session][:password]
    member_email = params[:session][:email]
    member = member_email.present? && Member.find_by(email: member_email)

    if member.valid_password? member_password
      sign_in member, store: false
      member.generate_authentication_token!
      member.save
      render json: member, status: 200, location: [:api, member]
    else
      render json: { errors: "Invalid email or password" }, status: 422
    end
  end
end

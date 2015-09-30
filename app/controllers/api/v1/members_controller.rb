class Api::V1::MembersController < ApplicationController
	respond_to :json

  def show
    respond_with Member.find(params[:id])
  end

  def create
    member = Member.new(member_params)
    if member.save
      render json: member, status: 201, location: [:api, member]
    else
      render json: { errors: member.errors }, status: 422
    end
  end

  private

    def member_params
      params.require(:member).permit(:email, :password, :password_confirmation)
    end
end

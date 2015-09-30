class Api::V1::MembersController < ApplicationController
	respond_to :json

  def show
    respond_with Member.find(params[:id])
  end
end

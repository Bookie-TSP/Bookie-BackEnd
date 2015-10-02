class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  after_filter :set_access_control_headers
  include Authenticable

  def set_access_control_headers
  	headers['Access-Control-allow-Origin'] = '*'
  end
end

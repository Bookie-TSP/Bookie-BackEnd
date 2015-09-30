module Authenticable

  # Devise methods overwrites
  def current_user
    @current_user ||= Member.find_by(auth_token: request.headers['Authorization'])
  end
end
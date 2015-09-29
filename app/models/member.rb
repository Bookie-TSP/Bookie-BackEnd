class Member < ActiveRecord::Base
  validates :auth_token, uniqueness: true
end

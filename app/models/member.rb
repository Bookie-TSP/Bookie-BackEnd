class Member < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :timeoutable

  validates :auth_token, uniqueness: true
  validates :first_name, :last_name, :phone_number, :identification_number, presence: true
	before_create :generate_authentication_token!
  has_many :addresses, dependent: :destroy
  has_many :line_stocks, dependent: :destroy
  has_many :stocks, through: :line_stocks
  has_many :orders
  has_one :cart
  def generate_authentication_token!
    begin
      self.auth_token = Devise.friendly_token
    end while self.class.exists?(auth_token: auth_token)
  end
end

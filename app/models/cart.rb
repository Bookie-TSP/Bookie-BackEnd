class Cart < ActiveRecord::Base
	has_many :stocks
  belongs_to :member, dependent: :destroy
end

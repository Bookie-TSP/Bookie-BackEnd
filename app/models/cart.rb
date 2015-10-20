class Cart < ActiveRecord::Base
	has_many :stocks
	has_and_belongs_to_many :stocks
  belongs_to :member, dependent: :destroy
end

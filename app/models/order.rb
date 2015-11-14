class Order < ActiveRecord::Base
  belongs_to :member
  has_and_belongs_to_many :stocks
  belongs_to :address
end

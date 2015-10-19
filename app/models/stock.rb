class Stock < ActiveRecord::Base
  belongs_to :book
  belongs_to :line_stock
  has_and_belongs_to_many :carts
  self.inheritance_column = :_type_disabled
end

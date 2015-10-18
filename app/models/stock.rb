class Stock < ActiveRecord::Base
  belongs_to :book
  belongs_to :line_stock
  belongs_to :cart
  self.inheritance_column = :_type_disabled
end

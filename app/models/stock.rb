class Stock < ActiveRecord::Base
  belongs_to :book
  belongs_to :linestock
end

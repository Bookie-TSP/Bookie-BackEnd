class LineStock < ActiveRecord::Base
  belongs_to :member
  belongs_to :book
  has_many :stocks
  self.inheritance_column = :_type_disabled
  validates_associated :stocks
end

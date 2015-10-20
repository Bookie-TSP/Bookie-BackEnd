class LineStock < ActiveRecord::Base
  belongs_to :member
  has_many :stocks, dependent: :destroy
  self.inheritance_column = :_type_disabled
  validates_associated :stocks
end

class LineStock < ActiveRecord::Base
  belongs_to :member
  has_many :stocks, dependent: :destroy
end

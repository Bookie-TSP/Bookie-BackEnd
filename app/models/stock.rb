class Stock < ActiveRecord::Base
	validates :book_id, :member_id, :status, :price, :type, :condition, :description, presence: true
  belongs_to :book
  belongs_to :line_stock
  has_and_belongs_to_many :carts
  self.inheritance_column = :_type_disabled

  def member
  	temp_member = Member.find_by_id(self.member_id)
  	temp_member.as_json(:include => :addresses)
	end
end

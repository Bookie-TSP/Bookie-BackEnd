class Stock < ActiveRecord::Base
	validates :book_id, :member_id, :status, :price, :type, :condition, :description, presence: true
  belongs_to :book
  belongs_to :line_stock
  has_and_belongs_to_many :orders
  has_and_belongs_to_many :carts
  self.inheritance_column = :_type_disabled


  validates_numericality_of :price, :greater_than_or_equal_to => 0
  validates_inclusion_of :type, :in => %w( sell lend )
  validates_inclusion_of :condition, :in => %w( new used )

  def member
  	temp_member = Member.find_by_id(self.member_id)
  	temp_member.as_json(:include => :addresses, :except => :auth_token)
	end

  def clear_cart
    self.carts.clear
  end
end

class Payment < ActiveRecord::Base
  belongs_to :order
  validates :billing_name, :billing_type, :billing_card_number, :billing_card_expire_date, :billing_card_security_number, presence: true

  validates_length_of :billing_card_number, :minimum => 16, :maximum => 16
  validates_length_of :billing_card_security_number, :minimum => 3, :maximum => 3

  validates_numericality_of :billing_card_number, only_integer: true
  validates_numericality_of :billing_card_security_number, only_integer: true

  validates_inclusion_of :billing_type, :in => %w( Visa MasterCard AmericanExpress Discover )
end

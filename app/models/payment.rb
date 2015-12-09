class Payment < ActiveRecord::Base
  belongs_to :order
  validates :billing_name, :billing_type, :billing_card_number, :billing_card_expire_date, :billing_card_security_number, presence: true

  validates_length_of :billing_card_number, :minimum => 16, :maximum => 16
end

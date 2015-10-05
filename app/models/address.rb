class Address < ActiveRecord::Base
	validates :first_name, :last_name, :latitude, :logitude, :information, presence: true
  belongs_to :member, dependent: :destroy
end

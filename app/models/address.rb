class Address < ActiveRecord::Base
	validates :first_name, :last_name, :latitude, :longitude, :information, presence: true
  belongs_to :member, dependent: :destroy
end

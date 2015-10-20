class Book < ActiveRecord::Base
	serialize :authors
	validates_uniqueness_of :ISBN10, :ISBN13, :allow_blank => true, :allow_nil => true
  validates :title, :authors, :language, :description, :cover_image_url, presence: true
	has_many :stocks, :dependent => :destroy
end
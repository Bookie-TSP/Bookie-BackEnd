class Book < ActiveRecord::Base
	validates_uniqueness_of :ISBN, :allow_blank => true, :allow_nil => true
  validates :name, :author, :language, presence: true
	has_many :stocks, :dependent => :destroy
end

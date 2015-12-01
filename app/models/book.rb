class Book < ActiveRecord::Base
	serialize :authors
	validates_uniqueness_of :ISBN10, :ISBN13, :publisher, :allow_blank => true, :allow_nil => true
  validates :title, :authors, :language, :cover_image_url, presence: true
	has_many :stocks, :dependent => :destroy
	has_many :line_stocks, :dependent => :destroy

	include PgSearch
  pg_search_scope :search_title, :against => [:title]
  pg_search_scope :search_ISBN10, :against => [:ISBN10]
  pg_search_scope :search_ISBN13, :against => [:ISBN13]
  pg_search_scope :search_publisher, :against => [:publisher]
  pg_search_scope :search_author, :against => [:authors]
end

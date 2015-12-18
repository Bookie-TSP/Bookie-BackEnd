class Book < ActiveRecord::Base
	serialize :authors
	validates_uniqueness_of :ISBN10, :ISBN13, :allow_blank => true, :allow_nil => true
  validates :title, :authors, :language, :cover_image_url, presence: true
	has_many :stocks, :dependent => :destroy
	has_many :line_stocks, :dependent => :destroy

  validates_length_of :ISBN10, :minimum => 10, :maximum => 10
  validates_numericality_of :ISBN10, only_integer: true

  validates_length_of :ISBN13, :minimum => 13, :maximum => 13
  validates_numericality_of :ISBN13, only_integer: true

  validates_numericality_of :pages, :only_integer => true, :greater_than_or_equal_to => 0, :allow_blank => true

	include PgSearch
  pg_search_scope :search_title, :against => [:title]
  pg_search_scope :search_ISBN10, :against => [:ISBN10]
  pg_search_scope :search_ISBN13, :against => [:ISBN13]
  pg_search_scope :search_publisher, :against => [:publisher]
  pg_search_scope :search_author, :against => [:authors]

  def lowest_price
  	price = self.stocks.where.not(:line_stock_id => nil).minimum(:price)
  	price.to_json
	end
end

class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :title
      t.string :ISBN10
      t.string :ISBN13
      t.text :authors
      t.string :language
      t.integer :pages
      t.string :publisher
      t.date :publish_date
      t.string :description
      t.string :cover_image_url

      t.timestamps null: false
    end
  end
end

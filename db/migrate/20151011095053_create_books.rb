class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :name
      t.string :ISBN
      t.string :author
      t.string :language
      t.integer :pages
      t.string :publisher

      t.timestamps null: false
    end
  end
end

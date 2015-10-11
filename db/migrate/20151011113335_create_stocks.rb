class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.references :book, index: true, foreign_key: true
      t.references :line_stock, index: true, foreign_key: true
      t.integer :member_id
      t.string :status
      t.float :price
      t.string :type
      t.string :condition
      t.string :duration
      t.string :terms

      t.timestamps null: false
    end
  end
end

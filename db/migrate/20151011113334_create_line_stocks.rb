class CreateLineStocks < ActiveRecord::Migration
  def change
    create_table :line_stocks do |t|
      t.references :member, index: true, foreign_key: true
      t.references :book, index: true, foreign_key: true
      t.integer :quantity
      t.string :type
      t.float :price
      t.string :condition
      t.string :duration
      t.string :terms
      t.string :description

      t.timestamps null: false
    end
  end
end

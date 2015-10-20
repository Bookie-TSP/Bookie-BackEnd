class CreateLineStocks < ActiveRecord::Migration
  def change
    create_table :line_stocks do |t|
      t.references :member, index: true, foreign_key: true
      t.integer :quantity
      t.string :type

      t.timestamps null: false
    end
  end
end

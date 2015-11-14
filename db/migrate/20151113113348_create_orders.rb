class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.references :member, index: true, foreign_key: true
      t.references :address, index: true, foreign_key: true
      t.string :status
      t.string :side
      t.float :total_price

      t.timestamps null: false
    end
  end
end

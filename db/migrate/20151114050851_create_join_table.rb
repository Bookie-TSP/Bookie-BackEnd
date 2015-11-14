class CreateJoinTable < ActiveRecord::Migration
  def change
    create_join_table :carts, :stocks do |t|
      t.index [:cart_id, :stock_id]
      t.index [:stock_id, :cart_id]
    end

    create_join_table :orders, :stocks do |t|
      t.index [:order_id, :stock_id]
      t.index [:stock_id, :order_id]
    end
  end
end

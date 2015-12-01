class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :order, index: true, foreign_key: true
      t.string :billing_name
      t.string :billing_type
      t.string :billing_card_number
      t.string :billing_card_expire_date
      t.integer :billing_card_security_number

      t.timestamps null: false
    end
  end
end

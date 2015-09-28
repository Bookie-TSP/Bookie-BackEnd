class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :email
      t.string :password
      t.string :first_name
      t.string :last_name
      t.string :phnoe_number
      t.string :identification_number
      t.string :gender
      t.date :birth_date

      t.timestamps null: false
    end
  end
end

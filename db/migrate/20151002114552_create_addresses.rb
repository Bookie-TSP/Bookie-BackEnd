class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :first_name
      t.string :last_name
      t.string :latitude
      t.string :longitude
      t.string :information
      t.references :member, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

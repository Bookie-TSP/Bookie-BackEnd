class CreateChaos < ActiveRecord::Migration
  def change
    create_table :chaos do |t|

      t.timestamps null: false
    end
  end
end

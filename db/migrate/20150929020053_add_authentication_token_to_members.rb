class AddAuthenticationTokenToMembers < ActiveRecord::Migration
  def change
    add_column :members, :auth_token, :string, default: ""
    add_index :members, :auth_token, unique: true
  end
end

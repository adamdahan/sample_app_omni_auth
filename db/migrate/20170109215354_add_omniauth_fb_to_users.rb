class AddOmniauthFbToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :token, :string
    add_column :users, :expires, :datetime
    add_column :users, :facebook_id, :string
    add_column :users, :picture, :string
  end
end

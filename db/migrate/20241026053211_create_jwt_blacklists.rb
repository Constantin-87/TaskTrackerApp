class CreateJwtBlacklists < ActiveRecord::Migration[7.0]
  def change
    create_table :jwt_blacklists do |t|
      t.string :jti, null: false  # jti is the unique identifier for the token
      t.datetime :exp, null: false # exp is the token expiration

      t.timestamps
    end
    add_index :jwt_blacklists, :jti
  end
end

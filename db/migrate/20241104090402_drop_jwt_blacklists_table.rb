class DropJwtBlacklistsTable < ActiveRecord::Migration[7.2]
  def up
    drop_table :jwt_blacklists, if_exists: true
  end

  def down
    create_table :jwt_blacklists do |t|
      t.string :jti, null: false
      t.datetime :exp
      t.timestamps
    end
    add_index :jwt_blacklists, :jti, unique: true
  end
end

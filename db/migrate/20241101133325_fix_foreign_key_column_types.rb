class FixForeignKeyColumnTypes < ActiveRecord::Migration[7.2]
  def up
    remove_foreign_key :users, :teams
    remove_foreign_key :tasks, :users

    change_column :users, :team_id, :bigint
    change_column :tasks, :user_id, :bigint

    add_foreign_key :users, :teams, column: :team_id
    add_foreign_key :tasks, :users, column: :user_id
  end

  def down
    remove_foreign_key :users, :teams, column: :team_id
    remove_foreign_key :tasks, :users, column: :user_id

    change_column :users, :team_id, :integer
    change_column :tasks, :user_id, :integer

    add_foreign_key :users, :teams, column: :team_id
    add_foreign_key :tasks, :users, column: :user_id
  end
end

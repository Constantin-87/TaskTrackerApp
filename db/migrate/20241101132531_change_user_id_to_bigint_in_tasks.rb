class ChangeUserIdToBigintInTasks < ActiveRecord::Migration[7.2]
  def up
    remove_foreign_key :tasks, :users
    change_column :tasks, :user_id, :bigint
    add_foreign_key :tasks, :users
  end

  def down
    remove_foreign_key :tasks, :users
    change_column :tasks, :user_id, :integer
    add_foreign_key :tasks, :users
  end
end

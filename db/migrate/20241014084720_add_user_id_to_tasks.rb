class AddUserIdToTasks < ActiveRecord::Migration[7.2]
  def change
    add_reference :tasks, :user, null: true, foreign_key: true
  end
end

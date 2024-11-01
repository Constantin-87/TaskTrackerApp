class FixUserIdForeignKeyInNotifications < ActiveRecord::Migration[7.2]
  def change
    # Remove the existing foreign key constraint
    remove_foreign_key :notifications, :users

    # Update the column to be bigint explicitly if not already done
    change_column :notifications, :user_id, :bigint

    # Re-add the foreign key constraint
    add_foreign_key :notifications, :users, column: :user_id
  end
end

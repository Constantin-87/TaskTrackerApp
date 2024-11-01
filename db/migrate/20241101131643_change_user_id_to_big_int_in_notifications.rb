class ChangeUserIdToBigIntInNotifications < ActiveRecord::Migration[7.2]
  def change
    change_column :notifications, :user_id, :bigint
  end
end

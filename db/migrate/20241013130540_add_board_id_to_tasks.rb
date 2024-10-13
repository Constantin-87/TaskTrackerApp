class AddBoardIdToTasks < ActiveRecord::Migration[7.2]
  def change
    add_column :tasks, :board_id, :integer
  end
end

class AddStatusAndPriorityToTasks < ActiveRecord::Migration[7.2]
  def change
    add_column :tasks, :status, :integer, default: 0  # Default to 'not_started'
    add_column :tasks, :priority, :integer, default: 1  # Default to 'medium'
  end
end

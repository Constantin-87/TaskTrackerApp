class ChangeDescriptionInTeams < ActiveRecord::Migration[7.2]
  def change
    change_column :teams, :description, :string, limit: 500
  end
end

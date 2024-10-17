class AddDescriptionToTeams < ActiveRecord::Migration[7.2]
  def change
    add_column :teams, :description, :string
  end
end

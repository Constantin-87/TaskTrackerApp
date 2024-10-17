class AddDescriptionToBoards < ActiveRecord::Migration[7.2]
  def change
    add_column :boards, :description, :string
  end
end

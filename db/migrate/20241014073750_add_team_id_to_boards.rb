class AddTeamIdToBoards < ActiveRecord::Migration[7.2]
  def change
    add_reference :boards, :team, null: true, foreign_key: true
  end
end

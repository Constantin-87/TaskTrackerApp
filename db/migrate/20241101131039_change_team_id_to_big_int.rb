class ChangeTeamIdToBigInt < ActiveRecord::Migration[7.2]
  def change
    change_column :boards, :team_id, :bigint
  end
end

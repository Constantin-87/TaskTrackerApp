class CreateJoinTableUsersTeams < ActiveRecord::Migration[7.2]
  def change
    create_join_table :users, :teams do |t|
      t.index :user_id
      t.index :team_id
    end
  end
end

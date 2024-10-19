class AddUniqueIndexesToTeamsAndBoards < ActiveRecord::Migration[7.2]
  def change
     # Remove duplicate teams before adding unique index
     duplicate_teams = Team.select(:name).group(:name).having("COUNT(*) > 1").pluck(:name)
     duplicate_teams.each do |name|
       teams_with_same_name = Team.where(name: name).order(:created_at)
       teams_with_same_name.offset(1).destroy_all # Keep the first one, remove the rest
     end

     # Remove duplicate boards before adding unique index
     duplicate_boards = Board.select(:name).group(:name).having("COUNT(*) > 1").pluck(:name)
     duplicate_boards.each do |name|
       boards_with_same_name = Board.where(name: name).order(:created_at)
       boards_with_same_name.offset(1).destroy_all # Keep the first one, remove the rest
     end

     # Add unique indexes
     add_index :boards, :name, unique: true
     add_index :teams, :name, unique: true
  end
end

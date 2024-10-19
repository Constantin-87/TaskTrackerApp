class UpdateForeignKeysForTeams < ActiveRecord::Migration[7.2]
  def change
    # Update foreign key for users to nullify on delete
    remove_foreign_key :users, :teams
    add_foreign_key :users, :teams, on_delete: :nullify

    # Update foreign key for boards to nullify on delete
    remove_foreign_key :boards, :teams
    add_foreign_key :boards, :teams, on_delete: :nullify
  end
end

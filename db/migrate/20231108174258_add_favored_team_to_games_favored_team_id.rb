class AddFavoredTeamToGamesFavoredTeamId < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :favored_team_id, :integer
  end
end

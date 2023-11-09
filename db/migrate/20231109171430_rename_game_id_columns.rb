class RenameGameIdColumns < ActiveRecord::Migration[7.1]
  def change
    rename_column :games, :game_id, :remote_game_id
    rename_column :picks, :game_id, :remote_game_id
    rename_column :picks, :team_id, :remote_team_id
    add_column :picks, :game_id, :integer
  end
end

class AddHomeAwayToGame < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :home_team, :string
    add_column :games, :away_team, :string
    add_column :games, :home_score, :integer
    add_column :games, :away_score, :integer
  end
end

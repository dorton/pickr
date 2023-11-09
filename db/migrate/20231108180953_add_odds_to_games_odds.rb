class AddOddsToGamesOdds < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :odds, :float
  end
end

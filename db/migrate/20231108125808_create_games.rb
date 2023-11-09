class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.integer :week
      t.integer :game_id
      t.integer :set_odds

      t.timestamps
    end
  end
end

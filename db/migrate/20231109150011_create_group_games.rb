class CreateGroupGames < ActiveRecord::Migration[7.1]
  def change
    create_table :group_games do |t|
      t.integer :game_id
      t.integer :group_id

      t.timestamps
    end
  end
end

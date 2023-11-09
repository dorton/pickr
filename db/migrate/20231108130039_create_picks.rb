class CreatePicks < ActiveRecord::Migration[7.1]
  def change
    create_table :picks do |t|
      t.integer :week
      t.integer :game_id
      t.integer :confidence
      t.integer :team_id

      t.timestamps
    end
  end
end

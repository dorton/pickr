class CreateMatchups < ActiveRecord::Migration[7.1]
  def change
    create_table :matchups do |t|
      t.string :remote_id
      t.string :sport_key
      t.string :sport_title
      t.datetime :commence_time
      t.boolean :completed, null: false, default: false
      t.string :home_team
      t.string :away_team
      t.datetime :remote_last_updated
      t.json :scores

      t.timestamps
    end
  end
end

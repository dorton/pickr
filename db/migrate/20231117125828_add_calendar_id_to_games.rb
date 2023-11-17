class AddCalendarIdToGames < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :calendar_id, :integer
  end
end

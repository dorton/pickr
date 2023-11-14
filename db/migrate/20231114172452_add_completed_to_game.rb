class AddCompletedToGame < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :completed, :boolean, default: :false
  end
end

class AddBookmakersToMatchups < ActiveRecord::Migration[7.1]
  def change
    add_column :matchups, :bookmakers, :json
  end
end

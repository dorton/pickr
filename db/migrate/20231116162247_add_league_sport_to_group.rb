class AddLeagueSportToGroup < ActiveRecord::Migration[7.1]
  def change
    add_column :groups, :league, :string
    add_column :groups, :sport, :string
    add_column :groups, :regular_season, :boolean, default: false
    add_column :groups, :post_season, :boolean, default: false
  end
end

class AddGroupIdToCalendar < ActiveRecord::Migration[7.1]
  def change
    add_column :calendars, :post_season, :boolean, default: false
    add_column :calendars, :regular_season, :boolean, default: false
    add_column :calendars, :league, :string
    add_column :calendars, :sport, :string
  end
end

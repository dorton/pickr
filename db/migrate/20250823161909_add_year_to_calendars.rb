class AddYearToCalendars < ActiveRecord::Migration[7.1]
  def change
    add_column :calendars, :year, :integer
    add_index :calendars, [:league, :sport, :year]

    # Backfill existing records from startDate or endDate
    reversible do |dir|
      dir.up do
        # SQLite compatible backfill using STRFTIME
        execute <<~SQL
          UPDATE calendars
          SET year = CAST(STRFTIME('%Y', COALESCE(startDate, endDate)) AS INTEGER)
          WHERE (startDate IS NOT NULL OR endDate IS NOT NULL) AND year IS NULL;
        SQL
      end
    end
  end
end

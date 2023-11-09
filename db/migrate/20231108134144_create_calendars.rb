class CreateCalendars < ActiveRecord::Migration[7.1]
  def change
    create_table :calendars do |t|
      t.string :label
      t.string :alternateLabel
      t.string :detail
      t.string :value
      t.datetime :startDate
      t.datetime :endDate

      t.timestamps
    end
  end
end

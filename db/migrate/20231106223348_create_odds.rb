class CreateOdds < ActiveRecord::Migration[7.1]
  def change
    create_table :odds do |t|
      t.string :remote_id
      t.string :title
      t.datetime :last_update
      t.string :market_type
      t.string :name
      t.string :price
      t.string :point

      t.timestamps
    end
  end
end

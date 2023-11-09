class CreateGroupPicks < ActiveRecord::Migration[7.1]
  def change
    create_table :group_picks do |t|
      t.integer :pick_id
      t.integer :group_id

      t.timestamps
    end
  end
end

class CreateGroupManagers < ActiveRecord::Migration[7.1]
  def change
    create_table :group_managers do |t|
      t.integer :user_id
      t.integer :group_id

      t.timestamps
    end
  end
end

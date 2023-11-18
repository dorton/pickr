class CreateUserGroupDefaults < ActiveRecord::Migration[7.1]
  def change
    create_table :user_group_defaults do |t|
      t.boolean :default
      t.integer :user_id
      t.integer :group_id

      t.timestamps
    end
  end
end

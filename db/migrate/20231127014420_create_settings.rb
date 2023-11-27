class CreateSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :settings do |t|
      t.string :theme, default: 'dark'
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

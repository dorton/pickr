class AddColumnsToGroup < ActiveRecord::Migration[7.1]
  def change
    add_column :groups, :max_picks, :integer, default: 10
    add_column :groups, :spread, :boolean, default: true
    add_column :groups, :over_under, :boolean, default: false
  end
end

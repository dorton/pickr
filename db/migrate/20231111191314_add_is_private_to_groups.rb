class AddIsPrivateToGroups < ActiveRecord::Migration[7.1]
  def change
    add_column :groups, :is_private, :boolean, default: false
  end
end

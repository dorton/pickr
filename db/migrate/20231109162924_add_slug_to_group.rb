class AddSlugToGroup < ActiveRecord::Migration[7.1]
  def change
    add_column :groups, :slug, :string
  end
end

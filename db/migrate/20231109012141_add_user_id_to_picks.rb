class AddUserIdToPicks < ActiveRecord::Migration[7.1]
  def change
    add_column :picks, :user_id, :integer
  end
end

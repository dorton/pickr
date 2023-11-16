class ChangeWeekColumnOnGame < ActiveRecord::Migration[7.1]
  def change
    change_column(:games, :week, :string)
  end
end

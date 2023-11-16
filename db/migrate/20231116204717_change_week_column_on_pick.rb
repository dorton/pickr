class ChangeWeekColumnOnPick < ActiveRecord::Migration[7.1]
  def change
    change_column(:picks, :week, :string)
  end
end

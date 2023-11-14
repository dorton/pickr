class AddWinnerToPick < ActiveRecord::Migration[7.1]
  def change
    add_column :picks, :winner, :boolean, default: :false
  end
end

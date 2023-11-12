class Group < ApplicationRecord
  # has_many :group_managers, dependent: :destroy
  # has_many :users, as: :manager, through: :group_managers
  has_many :user_groups, dependent: :destroy
  has_many :users, through: :user_groups
  has_many :group_games, dependent: :destroy
  has_many :games, through: :group_games
  has_many :group_picks, dependent: :destroy
  has_many :picks, through: :group_picks
end

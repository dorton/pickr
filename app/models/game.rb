class Game < ApplicationRecord
    has_many :picks, dependent: :destroy
    has_many :group_games, dependent: :destroy
    has_many :groups, through: :group_games
    belongs_to :calendar
end

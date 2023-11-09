class Pick < ApplicationRecord
    belongs_to :user
    belongs_to :game
    has_many :group_picks, dependent: :destroy
    has_many :groups, through: :group_picks
end

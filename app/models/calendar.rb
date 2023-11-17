class Calendar < ApplicationRecord
    has_many :games, dependent: :destroy
end

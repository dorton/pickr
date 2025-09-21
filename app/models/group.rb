class Group < ApplicationRecord
  has_many :group_managers, dependent: :destroy
  has_many :managers, through: :group_managers, source: :user
  has_many :user_group_defaults, dependent: :destroy
  has_many :defaults, through: :user_group_defaults, source: :user
  has_many :user_groups, dependent: :destroy
  has_many :users, through: :user_groups
  has_many :group_games, dependent: :destroy
  has_many :games, through: :group_games
  has_many :group_picks, dependent: :destroy
  has_many :picks, through: :group_picks

  after_commit :ensure_season_calendar, on: :create

  private

  def ensure_season_calendar
    sport = self.sport.presence || 'football'
    league = self.league.presence || 'college-football'
    current_year = Time.zone.now.year
    unless Calendar.exists?(sport: sport, league: league, year: current_year)
      NewSeasonSetup.call(sport: sport, league: league)
    end
  rescue => e
    Rails.logger.error("NewSeasonSetup failed for Group##{id} creation: #{e.class} - #{e.message}")
  end
end

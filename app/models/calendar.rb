class Calendar < ApplicationRecord
  has_many :games, dependent: :destroy

  validates :value, uniqueness: { scope: [:league, :sport, :year] }, allow_nil: true

  def self.get_all_calendars(group = nil, year = nil)
    calendars = if group
                  where(sport: group.sport, league: group.league)
                else
                  where(sport: 'football')
                end

    calendars = calendars.where(year: year) if year.present?
    calendars
  end

  def self.get_calendar_by_week_value(week_value, group = nil, year = nil)
    get_all_calendars(group, year).find_by(value: week_value)
  end

  def self.current_week(group = nil, week_id = nil, year = nil)
    if week_id.present?
      get_all_calendars(group, year).find_by(value: week_id)
    else
      get_all_calendars(group, year).where('? BETWEEN startDate AND endDate', Time.current).first
    end
  end
end

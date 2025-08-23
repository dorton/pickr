class Calendar < ApplicationRecord
  has_many :games, dependent: :destroy

  validates :value, uniqueness: { scope: [:league, :sport, :year] }, allow_nil: true

  def self.get_all_calendars(group = nil)
    if group
      where(sport: group.sport, league: group.league)
    else
      where(sport: 'football')
    end
  end

  def self.get_calendar_by_week_value(week_value)
    get_all_calendars.find_by(value: week_value)
  end

  def self.current_week(group = nil, week_id = nil)
    if week_id.nil?
      get_all_calendars(group).where('? BETWEEN startDate AND endDate', Time.current).first
    else
      get_all_calendars(group).find_by_value(week_id)
    end
  end
end

# frozen_string_literal: true

class NewSeasonSetup < ApplicationService
  def self.call(**kwargs)
    new(**kwargs).call
  end

  def initialize(sport: 'football', league: 'college-football', espn_data: nil)
    @sport = sport
    @league = league
    # Fetch season calendar; no specific week needed
    @espn_data = espn_data || EspnScores.call(nil, @sport, @league)
    leagues = @espn_data && @espn_data['leagues'] || []
    calendar = leagues.first && leagues.first['calendar'] || []
    @regular_entries = calendar.first && calendar.first['entries'] || []
    @post_entries = calendar.second && calendar.second['entries'] || []
  end

  def call
    created = 0
    updated = 0
    ActiveRecord::Base.transaction do
      created_reg, updated_reg = upsert_weeks(@regular_entries, post_season: false, regular_season: true, return_updates: true)
      created += created_reg
      updated += updated_reg
      created_post, updated_post = upsert_weeks(@post_entries, post_season: true, regular_season: false, return_updates: true)
      created += created_post
      updated += updated_post
    end
    { created: created, updated: updated }
  end

  private

  def upsert_weeks(entries, post_season:, regular_season:, return_updates: false)
    created = 0
    updated = 0
    entries.each do |week|
      value_prefix = post_season ? 'post' : 'week'
      value = "#{value_prefix}_#{week['value']}"
      # Compute year from startDate (or endDate fallback) before lookup
      dt = week['startDate'] || week['endDate']
      year = Time.zone.parse(dt).year if dt
      record = Calendar.find_or_initialize_by(value: value, league: @league, sport: @sport, year: year)
      record.label = week['label']
      record.alternateLabel = week['alternateLabel']
      record.detail = week['detail']
      record.value = value
      record.startDate = week['startDate']
      record.endDate = week['endDate']
      record.year = year if year
      record.post_season = post_season
      record.regular_season = regular_season
      if record.new_record?
        record.save!
        created += 1
      elsif record.changed?
        record.save!
        updated += 1
      end
    end
    return_updates ? [created, updated] : created
  end
end

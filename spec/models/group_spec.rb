require 'rails_helper'

RSpec.describe Group, type: :model do
  describe 'after create' do
    let(:league) { 'college-football' }
    let(:sport)  { 'football' }

    it 'calls NewSeasonSetup when no calendar exists for current year' do
      current_year = Time.zone.now.year
      expect(Calendar.exists?(sport: sport, league: league, year: current_year)).to be_falsey

      expect(NewSeasonSetup).to receive(:call).with(sport: sport, league: league)

      Group.create!(name: 'G1', slug: "g1-#{SecureRandom.hex(2)}", league: league, sport: sport, regular_season: true)
    end

    it 'does not call NewSeasonSetup when a calendar exists for current year' do
      current_year = Time.zone.now.year
      Calendar.create!(
        sport: sport,
        league: league,
        year: current_year,
        value: 'week_1',
        label: 'Week 1',
        alternateLabel: 'Wk 1',
        detail: 'Existing',
        startDate: Time.zone.now - 1.day,
        endDate: Time.zone.now + 1.day,
        regular_season: true
      )

      expect(NewSeasonSetup).not_to receive(:call)

      Group.create!(name: 'G2', slug: "g2-#{SecureRandom.hex(2)}", league: league, sport: sport, regular_season: true)
    end
  end
end


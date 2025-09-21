require 'rails_helper'
require 'securerandom'

RSpec.describe "Groups", type: :request do
  describe "POST /groups" do
    let!(:user) { User.create!(username: 'tester', email: 'tester@example.com', password: 'password123') }

    def group_params(overrides = {})
      {
        group: {
          name: 'Test Group',
          slug: "test-group-#{SecureRandom.hex(3)}",
          is_private: false,
          league: overrides.fetch(:league, 'college-football'),
          sport: overrides.fetch(:sport, 'football'),
          regular_season: true,
          post_season: false,
          max_picks: 10,
          spread: true,
          over_under: false
        },
        user: { id: user.id }
      }
    end

    it "calls NewSeasonSetup when no calendar exists for current year" do
      sign_in user

      current_year = Time.zone.now.year
      expect(Calendar.exists?(sport: 'football', league: 'college-football', year: current_year)).to be_falsey

      expect(NewSeasonSetup).to receive(:call).with(sport: 'football', league: 'college-football')

      post "/groups", params: group_params

      expect(response).to have_http_status(:created)
    end

    it "does not call NewSeasonSetup when a calendar exists for current year" do
      sign_in user

      current_year = Time.zone.now.year
      Calendar.create!(
        sport: 'football',
        league: 'college-football',
        year: current_year,
        value: 'week_1',
        label: 'Week 1',
        alternateLabel: 'Wk 1',
        detail: 'Preexisting',
        startDate: Time.zone.now - 1.day,
        endDate: Time.zone.now + 1.day,
        regular_season: true
      )

      expect(NewSeasonSetup).not_to receive(:call)

      post "/groups", params: group_params

      expect(response).to have_http_status(:created)
    end
  end
end

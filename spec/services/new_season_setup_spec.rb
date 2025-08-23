require 'rails_helper'

RSpec.describe NewSeasonSetup, type: :service do
  def sample_espn_data(detail_suffix: 'A', base_date: Time.current.beginning_of_year + 1.week)
    {
      'leagues' => [
        {
          'calendar' => [
            { 'entries' => [
              {
                'label' => 'Week 1',
                'alternateLabel' => 'Wk 1',
                'detail' => "Regular #{detail_suffix}",
                'value' => 1,
                'startDate' => base_date.iso8601,
                'endDate' => (base_date + 6.days).iso8601
              },
              {
                'label' => 'Week 2',
                'alternateLabel' => 'Wk 2',
                'detail' => "Regular #{detail_suffix}",
                'value' => 2,
                'startDate' => (base_date + 7.days).iso8601,
                'endDate' => (base_date + 13.days).iso8601
              }
            ]},
            { 'entries' => [
              {
                'label' => 'Round 1',
                'alternateLabel' => 'R1',
                'detail' => "Post #{detail_suffix}",
                'value' => 1,
                'startDate' => (base_date + 14.days).iso8601,
                'endDate' => (base_date + 20.days).iso8601
              }
            ]}
          ]
        }
      ]
    }
  end

  it 'creates regular and post season weeks idempotently and updates when data changes' do
    data = sample_espn_data(detail_suffix: 'A')

    result = described_class.call(sport: 'football', league: 'college-football', espn_data: data)
    expect(result).to eq({ created: 3, updated: 0 })

    w1 = Calendar.find_by(value: 'week_1', league: 'college-football', sport: 'football')
    expect(w1).to be_present
    expect(w1.post_season).to be false
    expect(w1.regular_season).to be true

    p1 = Calendar.find_by(value: 'post_1', league: 'college-football', sport: 'football')
    expect(p1).to be_present
    expect(p1.post_season).to be true
    expect(p1.regular_season).to be false

    # Calling again with same data shouldn't create or update
    result2 = described_class.call(sport: 'football', league: 'college-football', espn_data: data)
    expect(result2).to eq({ created: 0, updated: 0 })

    # Change one field for an update
    data2 = sample_espn_data(detail_suffix: 'B')
    result3 = described_class.call(sport: 'football', league: 'college-football', espn_data: data2)
    expect(result3).to eq({ created: 0, updated: 3 })
  end

  it 'does not overwrite previous seasons when the year changes' do
    # First season (e.g., 2024)
    base_2024 = Time.zone.parse('2024-08-01')
    data_2024 = sample_espn_data(detail_suffix: 'Y24', base_date: base_2024)
    res_24 = described_class.call(sport: 'football', league: 'college-football', espn_data: data_2024)
    expect(res_24).to eq({ created: 3, updated: 0 })

    # Second season (e.g., 2025) with same week values but different year
    base_2025 = Time.zone.parse('2025-08-01')
    data_2025 = sample_espn_data(detail_suffix: 'Y25', base_date: base_2025)
    res_25 = described_class.call(sport: 'football', league: 'college-football', espn_data: data_2025)
    expect(res_25).to eq({ created: 3, updated: 0 })

    # Ensure both years exist for the same week value
    w1_2024 = Calendar.find_by(value: 'week_1', league: 'college-football', sport: 'football', year: 2024)
    w1_2025 = Calendar.find_by(value: 'week_1', league: 'college-football', sport: 'football', year: 2025)
    expect(w1_2024).to be_present
    expect(w1_2025).to be_present
    expect(w1_2024.detail).to include('Y24')
    expect(w1_2025.detail).to include('Y25')
  end
end

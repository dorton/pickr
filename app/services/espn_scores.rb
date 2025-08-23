class EspnScores < ApplicationService
  include MakeEspnCall

  def initialize(week_slug='week_1', sport = 'football', league = 'college-football')
    @week_slug = week_slug
    @week_type = @week_slug.split('_').first
    @week_value = @week_slug.split('_').last
    @sport = sport
    @league = league
  end

  def call
    get_scores
  end
end

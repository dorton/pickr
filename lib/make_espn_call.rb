module MakeEspnCall
  include HTTParty
  def get_scores
    url_sport = 'football' if @league == 'college-football' || @league == 'nfl'
    season_type = @week_type == 'post' ? 3 : 2 if @week_type
    queries = []
    queries.push('groups=80') if @league == 'college-football'
    queries.push("seasontype=#{season_type}")
    queries.push('seasontype=2')
    queries.push("week=#{@week_value}") if @week_value
    url = "https://site.api.espn.com/apis/site/v2/sports/#{url_sport}/#{@league}/scoreboard?#{queries.join('&')}"
    HTTParty.get(url)
  end
end

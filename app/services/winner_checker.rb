class WinnerChecker < ApplicationService
  def initialize(week_slug, league = 'college-football', sport = 'sport', remote_games = nil)
    @week_slug = week_slug || Calendar.current_week.value
    @league = league
    @sport = sport
    @remote_games = remote_games
  end

  def call
    checker
  end

  private

  def checker
    @remote_games ||= EspnScores.call(@week_slug, @sport, @league)
    saved_games = Game.includes(:picks).where(week: @week_slug)
    saved_games.each do |game|
      game.picks.each do |pick|
        line = pick.remote_team_id == game.odds && game.favored_team_id ? game.odds.abs : game.odds
        favored_score = pick.remote_team_id == game.home_team_id ? 'home_score' : 'away_score'
        other_score = favored_score == 'away_score' ? 'home_score' : 'away_score'
        if line && ((game[favored_score].to_i - game[other_score].to_i) > line) && game.completed
          pick.update(winner: true)
        end
      end
    end
  end
end

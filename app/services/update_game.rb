class UpdateGame < ApplicationService
  def initialize(saved_game, remote_games)
    @saved_game = saved_game
    @remote_games = remote_games
  end

  def call
    update_game
  end

  private

  def update_game
    remote_game = @remote_games.find { |rg| rg['id'].to_i == @saved_game['remote_game_id'].to_i }
    home = get_home_away_team(remote_game, 'home')
    away = get_home_away_team(remote_game, 'away')
    data = {
      home_score: home['score'],
      away_score: away['score'],
      home_team: home['team']['location'],
      away_team: away['team']['location'],
      home_team_id: home['id'],
      away_team_id: away['id'],
      completed: remote_game['competitions'].first['status']['type']['completed']
    }
    @saved_game.update(data)
  end
end

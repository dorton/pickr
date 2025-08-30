class UpdateGame < ApplicationService
  def initialize(saved_game, remote_games)
    super()
    @saved_game = saved_game
    @remote_games = remote_games
  end

  def call
    update_game
  end

  private

  def get_home_away_team(remote_game, type)
    return nil unless remote_game && remote_game['competitions']&.first

    remote_game['competitions'].first['competitors']&.find { |team| team['homeAway'] == type }
  end

  def update_game
    remote_game = @remote_games.find { |rg| rg['id'].to_i == @saved_game['remote_game_id'].to_i }
    return unless remote_game

    home = get_home_away_team(remote_game, 'home')
    away = get_home_away_team(remote_game, 'away')
    return unless home && away

    data = {
      home_score: home['score'],
      away_score: away['score'],
      home_team: home.dig('team', 'location'),
      away_team: away.dig('team', 'location'),
      home_team_id: home['id'],
      away_team_id: away['id'],
      completed: remote_game.dig('competitions', 0, 'status', 'type', 'completed')
    }
    @saved_game.update(data)
  end
end

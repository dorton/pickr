module MatchupsHelper

    def espnScores(week_slug, sport=nil, league='college-football')
        sport = 'football' if league == 'college-football' || league ==  'nfl'
        queries = []
        queries.push('groups=80') if league == 'college-football'
        queries.push("week=#{week_slug.split('_').last}") if week_slug.split('_').count > 1
        url = "https://site.api.espn.com/apis/site/v2/sports/#{sport}/#{league}/scoreboard?#{queries.join('&')}"
        logger.info("~~~~~~~~~~~~~~~#{url}~~~~~~~~~~~~~~~~~~~~")
        games = HTTParty.get(url)
    end

    def current_week(week_id=nil)
        if week_id.nil?
            Calendar.where('? BETWEEN startDate AND endDate', Time.now).first
        else
            Calendar.find_by_value(week_id)
        end   
    end

    def weeks_games(week_slug)
        Game.includes(:picks).where(week: week_slug)
    end

    def update_game(saved_game, remote_games)
        remote_game = remote_games.find{ |rg| rg['id'].to_i == saved_game['remote_game_id'].to_i }
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
        saved_game.update(data)
    end

    def handle_updating_games(week_slug, league, sport='football')
        remote_games = espnScores(week_slug, sport, league)["events"]
        saved_games = weeks_games(week_slug)
        saved_games.each do |game|
            
        end
    end

    def get_home_away_team(remote_game, homeAway)
        remote_game['competitions'].first['competitors'].find{|c| c['homeAway'] == homeAway}
    end
    

    def handle_winning_picks(week_slug, league, sport='football', remote_games=nil)
        if !remote_games
            remote_games = espnScores(week_slug, sport, league)["events"]
        end
        saved_games = weeks_games(week_slug)
        saved_games.each do |game|
            game.picks.each do |pick|
                line = pick.remote_team_id == game.favored_team_id ? game.odds.abs : game.odds
                favored_score = pick.remote_team_id == game.home_team_id ? 'home_score' : 'away_score'
                other_score = favored_score == 'away_score' ?  'home_score' : 'away_score'
                if line && ((game[favored_score].to_i - game[other_score].to_i) > line)
                    pick.update(winner: true) if game.completed
                end
            end
        end
    end

    def correct_pick(remote_favored_team, remote_picked_team, remote_other_team, saved_game)
        line = remote_favored_team['id'].to_i == remote_picked_team['id'].to_i ? saved_game.odds.abs : saved_game.odds
        
        remote_picked_team['score'].to_i - remote_other_team['score'].to_i > line
    end
    

    def remote_game_from_id(remote_game, id)
        remote_game['competitions'].first['competitors'].find{ |c| c['id'].to_i == id}
    end
    
    
    

    def handleScores
        matches = HTTParty.get('https://api.the-odds-api.com/v4/sports/americanfootball_ncaaf/scores?apiKey=cdcaf10005b3d83980a203803535b3d4&daysFrom=2')
        matches.each do |match|
                m = Matchup.find_or_initialize_by(remote_id: match["id"]) 
                m.sport_key = match["sport_key"]
                m.sport_title = match["sport_title"]
                m.commence_time = match["commence_time"]
                m.completed = ActiveRecord::Type::Boolean.new.cast(match["completed"])
                m.home_team = match["home_team"]
                m.away_team = match["away_team"]
                m.remote_last_updated = match["last_update"]
                m.scores = match["scores"].to_json
                m.save
               
             end
    end
    def handleOdds
        matches = HTTParty.get('https://api.the-odds-api.com/v4/sports/americanfootball_ncaaf/odds?apiKey=cdcaf10005b3d83980a203803535b3d4&regions=us&markets=spreads&oddsFormat=american')
        matches.each do |match|
            m = Matchup.find_or_initialize_by(remote_id: match["id"])
            m.sport_key = match["sport_key"]
            m.sport_title = match["sport_title"]
            m.commence_time = match["commence_time"]
            m.home_team = match["home_team"]
            m.away_team = match["away_team"]
            m.remote_last_updated = match["last_update"]
            m.bookmakers = match["bookmakers"].to_json
            m.save

            id = match["id"]
            match["bookmakers"].each do |book|
                title = book["title"]
                last_update = book["last_update"]
                book["markets"].each do |market|
                    market_type = market["key"]
                    market["outcomes"].each do |outcome|
                        name = outcome["name"]
                        price = outcome["price"]
                        point = outcome["point"]
                        Odd.create(remote_id: id, title: title, last_update: last_update, market_type: market_type, name: name, price: price, point: point)
                    end
                end
            end
        end
    end
end

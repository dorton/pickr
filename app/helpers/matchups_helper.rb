module MatchupsHelper

    def espnScores(week)
        url = "https://site.api.espn.com/apis/site/v2/sports/football/college-football/scoreboard?week=#{week}&groups=80"
        games = HTTParty.get(url)
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

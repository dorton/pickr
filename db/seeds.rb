# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

['nfl', 'college-football'].each do |l|
    url = "https://site.api.espn.com/apis/site/v2/sports/football/#{l}/scoreboard"
    games = HTTParty.get(url)
    reg_season = games["leagues"].first["calendar"].find{|l| l["label"] == "Regular Season"}["entries"]
    post_season = games["leagues"].first["calendar"].find{|l| l["label"] == "Postseason"}["entries"]
    [reg_season, post_season].each_with_index do |season, i|
        regular_season_bool = i == 0
        post_season_bool = i == 1
        season.each do |s|
            svalue = s["value"]
            v = regular_season_bool ? "week_#{svalue}" : "post_#{svalue}"
            Calendar.create(label: s["label"], alternateLabel: s["alternateLabel"], detail: s["detail"], value: v, startDate: s["startDate"], endDate: s["endDate"], league: l, sport: 'football', regular_season: regular_season_bool, post_season: post_season_bool)
        end
    end
end

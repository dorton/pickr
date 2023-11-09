# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

url = "https://site.api.espn.com/apis/site/v2/sports/football/college-football/scoreboard?week=11&groups=80"
games = HTTParty.get(url)
reg_season = games["leagues"].first["calendar"].find{|l| l["label"] == "Regular Season"}["entries"]
post_season = games["leagues"].first["calendar"].find{|l| l["label"] == "Postseason"}["entries"]
reg_season.each do |s|
    Calendar.create(label: s["label"], alternateLabel: s["alternateLabel"], detail: s["detail"], value: s["value"], startDate: s["startDate"], endDate: s["endDa
    te"])
end
post_season.each do |s|
    Calendar.create(label: s["label"], alternateLabel: s["alternateLabel"], detail: s["detail"], value: s["value"], startDate: s["startDate"], endDate: s["endDa
    te"])
end
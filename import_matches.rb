require 'faraday'
require 'json'
require 'time'
require 'date'

def import_matches(league)
  conn = Faraday.new( :url => 'http://api.football-data.org', :headers => {'X-Auth-Token' => '__X_AUTH_TOKEN__'})
  response = conn.get "/v1/competitions/#{league}/fixtures"
  results = JSON.parse response.body
  
  open('Matchday/db/seeds.rb', 'a') { |f|
    results['fixtures'].each do |fixture|
      league    = URI(fixture['_links']['competition']['href']).path.split('/').last
      home_team = URI(fixture['_links']['homeTeam']['href']).path.split('/').last
      away_team = URI(fixture['_links']['awayTeam']['href']).path.split('/').last
      home_goals = fixture['result']['goalsHomeTeam'] ? fixture['result']['goalsHomeTeam'] : 0
      away_goals = fixture['result']['goalsAwayTeam'] ? fixture['result']['goalsAwayTeam'] : 0
      date = fixture['date']
      f.puts "Match.create( league: League.find_by_api_football_data_id(#{league}), home_team: Team.find_by_api_football_data_id(#{home_team}), away_team: Team.find_by_api_football_data_id(#{away_team}), matchday: #{fixture['matchday']},date: '#{date}',status: '#{fixture['status']}',home_team_goals: #{home_goals}, away_team_goals: #{away_goals})"
    end
  }
end

leagues = [426,436,430,438,434,433]

leagues.each do |league|
  puts ""
  puts "Importing matches from League ##{league}"
  import_matches(league)
  puts "Done!"
  sleep(3)
  break
end
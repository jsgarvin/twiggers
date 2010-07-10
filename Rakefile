# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

#require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'stalker'
require 'hot_spot'
require 'twitter'

task :default, :filename, :twitter_account do |t,args|
  config = YAML.load_file("config.yml")
  hot_spots_ahead = HotSpot.build_from_yml("#{args[:filename]}.yml")
  hot_spots_behind = []
  puts "###############################################"
  puts "Using File: #{args[:filename]}.yml"
  puts "Using Twitter Account: #{args[:twitter_account]} => #{!config[args[:twitter_account]]['atoken'].nil?}"
  puts "###############################################"
  
  oauth = Twitter::OAuth.new(config['token'],config['secret'])
  oauth.authorize_from_access(config[args[:twitter_account]]['atoken'],config[args[:twitter_account]]['asecret'])
  @twitter_client = Twitter::Base.new(oauth)
  while hot_spots_ahead.size > 0 do
    position = Stalker.last_known_position
    next_hot_spot = hot_spots_ahead.first
    unless next_hot_spot.perimeter_breached?
      distance = Geodesic::dist_haversine(next_hot_spot.latitude,next_hot_spot.longitude,position.lat,position.lon)
      puts "Distance: #{distance}"
      if distance <= next_hot_spot.actuate_distance.to_f/1000
        puts 'Breached!'
        next_hot_spot.perimeter_breached!
      end
    end
    if next_hot_spot.perimeter_breached?
      bearing = Geodesic::bearing(next_hot_spot.latitude,next_hot_spot.longitude,position.lat,position.lon)
      puts "Bearing: #{bearing}"
      if next_hot_spot.check_bearing(bearing)
        next_hot_spot.trigger!(position,Stalker.last_time_located)
        puts "Meters Traveled: #{next_hot_spot.meters_traveled}"
        puts "Past HotSpot: #{next_hot_spot.meters_traveled_past_hot_spot}"
        puts "Time Triggered: #{next_hot_spot.time_triggered}"
        puts "Time Located: #{next_hot_spot.time_located}"
        puts "Tweeting! : #{next_hot_spot.message}"
        if next_hot_spot.predecessor
          puts "Predecessor Meters Traveled: #{next_hot_spot.predecessor.meters_traveled}"
          puts "Predecessor Past HotSpot: #{next_hot_spot.predecessor.meters_traveled_past_hot_spot}"
          puts "Predecessor Time Triggered: #{next_hot_spot.predecessor.time_triggered}"
          puts "Predecessor Time Located: #{next_hot_spot.predecessor.time_located}"
        end
        begin
          @twitter_client.update(next_hot_spot.message) if next_hot_spot.message
        rescue
        end
        hot_spots_behind << next_hot_spot
        hot_spots_ahead.shift
      end
    end
    sleep 45
  end
end
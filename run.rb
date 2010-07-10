require 'stalker'
config = YAML.load_file("config.yml")
twiggers = Twigger.build_from_yml("twiggers.yml")

oauth = Twitter::OAuth.new(config['token'],config['secret'])
oauth.authorize_from_access(config['test_account']['atoken'],config['test_account']['asecret'])
@twitter_client = Twitter::Base.new(oauth)
    
while twiggers.size > 0 do
  position = Stalker.last_known_position
  twigger = twiggers.first
  unless twigger.perimeter_breached?
    distance = Geodesic::dist_haversine(twigger.latitude,twigger.longitude,position.lat,position.lon)
    if distance <= twigger.actuate_distance/1000
      twigger.permieter_breached!
    end
  end
  if twigger.perimeter_breached?
    bearing = Geodesic::bearing(twigger.latitude,twigger.longitude,position.lat,position.lon)
    if twigger.check_bearing(bearing)
      @twitter_client.update(twigger.message)
      twiggers.shift
    end
  end
end

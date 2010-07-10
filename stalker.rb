class Stalker
  require 'rubygems'
  require 'json'
  require 'open-uri'
  require 'geodesic'
  require 'yaml' 

  CONFIG = YAML.load_file("config.yml")

  class << self
    def last_known_position
      begin
        page = JSON(open("https://www.instamapper.com/api?action=getPositions&key=#{CONFIG['imapper_key']}&num=1&format=json").read)
      rescue
        puts "Instamapper connection failure."
        sleep 5;
      end
      @position = page['positions'][0]
      puts @position.inspect
      return Geodesic::Position.new(@position['latitude'], @position['longitude'])
    end
    
    def last_time_located
      return nil unless @position
      Time.at(@position['timestamp'])
    end
  end

end
class HotSpot
  #attr_accessor :hotspot_position, :message, :latitude, :longitude, :actuate_bearing, :actuate_precision, :actuate_distance,
  #  :hotspot_meters, :time_triggered, :time_located, :predecessor, :successor
  
  attr_accessor :meters, :time_triggered, :latitude, :longitude, :position, :predecessor, :successor, :actuate_distance, :time_located
  
  class << self
    def build_from_yml(path)
      yml = YAML.load_file(path)
      hot_spots = []
      yml.keys.each do |key|
        hot_spots << HotSpot.new(yml[key]['position'],yml[key]['message'],yml[key]['latitude'],yml[key]['longitude'],yml[key]['actuate_bearing'],yml[key]['actuate_precision'],yml[key]['actuate_distance'],yml[key]['meters'])
      end
      hot_spots = hot_spots.sort {|a,b| a.position <=> b.position }
      predecessor = nil
      hot_spots.map! do |hot_spot|
        predecessor.successor = hot_spot if predecessor
        hot_spot.predecessor = predecessor
        predecessor = hot_spot
        hot_spot
      end
    end
  end
  
  def initialize(position,message,latitude,longitude,bearing,precision,distance,meters)
    @position = position
    @message = message
    @latitude = latitude
    @longitude = longitude
    @actuate_bearing = bearing
    @actuate_precision = precision
    @actuate_distance = distance
    @meters = meters
  end
  
  def perimeter_breached?; @perimeter_breached; end
  def perimeter_breached!; @perimeter_breached = true; end
  
  def trigger!(triggered_position,time_located)
    @time_triggered = Time.now
    @time_located = time_located
    @triggered_position = triggered_position
  end
    
  def check_bearing(bearing)
    max = @actuate_bearing + @actuate_precision/2
    min = @actuate_bearing - @actuate_precision/2
    return ((bearing <= max and bearing >= min) or (bearing+360 <= max and bearing+360 >= min) or (bearing-360 <= max and bearing-360 >= min))
  end
  
  def message; @message; end
  
  def message_with_variable_substitution
    mess = message_without_variable_substitution
    if mess =~ /\%pace/
      mess.gsub!(/\%pace/,"#{sprintf("%.1f",minutes_per_mile_pace)}")
    end
    if mess =~ /\%timestamp/
      mess.gsub!(/\%timestamp/,"#{@time_located.hour}:#{@time_located.min}")
    end
    if mess =~ /\%etf/
      mess.gsub!(/\%etf/,"#{etf_in_twelve_hour_format}")
    end
    return mess
  end
  alias_method :message_without_variable_substitution, :message
  alias_method :message, :message_with_variable_substitution
  
  def time_since_predecessor
    self.predecessor ? (@time_located - self.predecessor.time_located) : nil
  end
  
  def meters_traveled_since_predecessor
    self.predecessor ? (meters_traveled - self.predecessor.meters_traveled) : nil
  end
  
  def meters_traveled_past_hot_spot
    @triggered_position.nil? ? 0 : (Geodesic::dist_haversine(@latitude,@longitude,@triggered_position.lat,@triggered_position.lon)*1000)
  end
  
  def meters_traveled
    @meters + meters_traveled_past_hot_spot
  end
  
  def minutes_per_mile_pace
    self.predecessor.nil? ? 0 : ((self.time_since_predecessor.to_f/60)/(self.meters_traveled_since_predecessor.to_f/1609.344))
  end
  
  def minutes_per_kilometer_pace
    self.predecessor.nil? ? 0 : ((self.time_since_predecessor.to_f/60)/(self.meters_traveled_since_predecessor.to_f/1000))
  end
  
  def meters_to_go
    successor.nil? ? 0 : successor.meters_to_go + (successor.meters - meters_traveled)
  end
  
  def minutes_to_go
    (meters_to_go.to_f/1000)*minutes_per_kilometer_pace
  end
  
  def etf
    Time.now + minutes_to_go*60
  end
  
  def etf_in_twelve_hour_format
    hour = etf.hour
    suffix = 'AM'
    if (hour > 12)
      hour -= 12
      suffix = 'PM'
    end
    return "#{hour}:#{etf.min}#{suffix}"
  end
end
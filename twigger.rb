require 'rubygems'
require 'twitter'
require 'json'
require 'open-uri'

config = YAML.load_file("config.yml")

# http://www.instamapper.com/api?action=getPositions&key=11030323885521488835&num=10&format=json
page = open("https://www.instamapper.com/api?action=getPositions&key=#{config['imapper_key']}&num=10&format=json")
doc = JSON page.read

puts doc['positions'][0]['latitude']
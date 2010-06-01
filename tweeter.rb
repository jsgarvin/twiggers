require 'rubygems'
require 'twitter'

config = YAML.load_file("config.yml")

oauth = Twitter::OAuth.new(config['token'],config['secret'])
oauth.authorize_from_access(config['test_account']['atoken'],config['test_account']['asecret'])

client = Twitter::Base.new(oauth)
result = client.update('Hello, Again!')

puts result.inspect
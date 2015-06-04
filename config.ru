# require "rubygems"
require "./lib/racker"

use Rack::Static, :urls => ["/stylesheets"], :root => "public"
# use Rack::Session::Cookie,  :key => 'rack.session',
#                             :secret => 'some_key'
# run lambda {|env|
#   # Rather than manipulating cookies ourselves, the upstream middleware gave
#   # us a helper object to set and read cookies

#   puts env['rack.session']  # read what's in our session
#   env['rack.session']['some_key'] = 'some_value'  # written to cookie for us
# }
# use Rack::Reloader
run Racker
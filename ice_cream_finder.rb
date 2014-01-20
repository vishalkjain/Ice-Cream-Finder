#take our query and parse it into the url request
#send request to api
#receive JSON with response (all our info)
#parse JSON into ruby
require 'rest-client'
require 'addressable/uri'
require 'json'
require 'nokogiri'

current_address = "770 Broadway, New York, NY 10003"

# Get current address from user

current_location_url = Addressable::URI.new(
:scheme => "https",
:host => "maps.googleapis.com",
:path => "maps/api/geocode/json",
:query_values => { :address => current_address, :sensor => false }
).to_s

geo_response = RestClient.get(current_location_url)
awful_hash = JSON.parse(geo_response)
lat, long = awful_hash["results"][0]["geometry"]["location"].values


search_url = Addressable::URI.new(
:scheme => "https",
:host => "maps.googleapis.com",
:path => "maps/api/place/nearbysearch/json",
:query_values => {:location => "#{lat},#{long}", :radius => 1000, :types => "food", :sensor => false, :name => "ice cream", :key => "AIzaSyC7WIK3beVmbIdb6QpTeKsrwhkK-P7yRwo"}
).to_s

search_response = RestClient.get(search_url)
search_results = JSON.parse(search_response)
shop_lat, shop_long = search_results["results"][0]["geometry"]["location"].values


directions_url = Addressable::URI.new(
  :scheme => "https",
  :host => "maps.googleapis.com",
  :path => "maps/api/directions/json",
  :query_values => {  :origin => "#{lat},#{long}",
                      :destination => "#{shop_lat},#{shop_long}",
                      :mode => "walking",
                      :sensor => false}
  ).to_s

  directions = RestClient.get(directions_url)

  instructions = JSON.parse(directions)["routes"][0]["legs"][0]["steps"].map do |el|
    el["html_instructions"]
  end

  done = instructions.map { |instruction| Nokogiri::HTML(instruction).text }
  p done

# #add later param: "opennow"


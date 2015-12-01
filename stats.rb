#!/usr/bin/env ruby

require 'net/https'
require 'csv'
require 'JSON'

region_param = 'region_id=13' # 13 is the loop, list here: http://bit.ly/103beCf
time_param = "$where=time > '2015-01-11' and time < '2015-01-12'" # date range

uri = URI.parse(URI.escape("https://data.cityofchicago.org/resource/historical-traffic-congestion-region.json?#{region_param}&#{time_param}"))

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_PEER

request = Net::HTTP::Get.new(uri.request_uri)
request.add_field('X-App-Token', ARGV[0])

response = http.request(request)
puts response.code

CSV.open("output.csv", "wb") { |csv| csv << ["time", "speed", "number_of_reads", "region_id", "bus_count"] }

CSV.open("output.csv", "a+") do |csv|
  JSON.parse(response.body).each do |h|
  	arr = []
  	h.each { |_,v| arr << v}
  	csv << arr
  end
end
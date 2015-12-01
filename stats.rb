#!/usr/bin/env ruby

require 'net/https'
require 'csv'
require 'JSON'

def make_request(region_param, time_param)
  uri = URI.parse(URI.escape("https://data.cityofchicago.org/resource/historical-traffic-congestion-region.json?#{region_param}&#{time_param}"))

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER

  request = Net::HTTP::Get.new(uri.request_uri)
  # pass app token as command line argument
  # get app token here: https://data.cityofchicago.org/developers/docs/historical-traffic-congestion-region
  request.add_field('X-App-Token', ARGV[0]) 

  response = http.request(request)
  puts response.code
  response.body
end

def main
  # path is 1->3->6->10->13
  # 13 is the loop, list here: http://bit.ly/103beCf
  path = [1, 3, 6, 10, 13]
  time_param = "$where=time > '2010-12-01' and time < '2015-12-01'" # date range

  CSV.open("output.csv", "wb") { |csv| csv << ["time", "speed", "number_of_reads", "region_id", "bus_count"] }

  path.each do |region_id|
    region_param = "region_id=#{region_id}"
    body = JSON.parse(make_request(region_param, time_param))
    CSV.open("output.csv", "a+") do |csv|
      body.each do |h|
        arr = []
        h.each { |_,v| arr << v}
        csv << arr
      end
    end
  end
end

main
require "uri"
require "json"
require "net/http"

module GoogleMaps
  class Base
    def call(origins, destinations)
      begin
        url = URI("https://maps.googleapis.com/maps/api/distancematrix/json")

        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true

        request = Net::HTTP::Get.new(address(origins, destinations))
        response = https.request(request)
        result = JSON.parse(response.body)
      rescue
        # Rollbar notification
        {}
      end
    end

    def address(origins, destinations)
      URI("https://maps.googleapis.com/maps/api/distancematrix/json?origins=#{origins[:latitude]}%2C#{origins[:longitude]}&destinations=#{destinations[:latitude]}%2C#{destinations[:longitude]}&key=#{ENV.fetch("GOOGLE_MAP_API")}")
    end
  end
end

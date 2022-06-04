module GoogleMaps
  class Distance < Base
    attr_accessor :result, :errors

    def initialize(origins, destinations)
      @origins = origins
      @destinations = destinations
    end

    def response
      call(@origins, @destinations)
    end

    def build_response
      response_data = response

      if response_data.empty?
        @errors = "Connection failure"
      else
        @result = response_data
      end
    end
  end
end

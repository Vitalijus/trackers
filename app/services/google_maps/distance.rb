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
      if response.empty?
        @errors = "Connection failure"
      else
        @result = response
      end
    end
  end
end

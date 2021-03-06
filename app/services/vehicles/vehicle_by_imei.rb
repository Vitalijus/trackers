class Vehicles::VehicleByImei < Vehicles::Base
  attr_accessor :errors, :result

  def initialize(tracker_imei)
    @tracker_imei = tracker_imei
  end

  def call
    response = HTTP.post(base_address, params: { query: query(@tracker_imei) })
    response.parse
  rescue HTTP::Error => e
    Rails.logger.error("VehicleByImei: #{e.message}")
    Rollbar.error("VehicleByImei: #{e.message}")
    {}
  end

  def build_response
    response = call

    if response.empty?
      @errors = "Connection failure"
    elsif response["errors"].present?
      @errors = "#{response["errors"]}"
    else
      @result = process_response(response)
    end
  end

  private

  def process_response(response)
    return if response["data"]["vehicleByImei"].nil?

    response["data"]["vehicleByImei"]["id"]
  end

  def query(tracker_imei)
    <<~GQL
    query vehicleByImei {
      vehicleByImei(trackerImei: "#{tracker_imei}"){
        id
      }
    }
    GQL
  end
end

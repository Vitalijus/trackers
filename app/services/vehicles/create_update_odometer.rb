class Vehicles::CreateUpdateOdometer < Vehicles::Base
  attr_accessor :errors, :result

  def initialize(odometer_params)
    @odometer_params = odometer_params
  end

  def call
    response = HTTP.post(base_address, params: { query: query(@odometer_params) })
    response.parse
  rescue HTTP::Error => e
    Rails.logger.error("CreateUpdateOdometer: #{e.message}")
    Rollbar.error("CreateUpdateOdometer: #{e.message}")
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
    return if response["data"]["createUpdateOdometer"].nil?

    response["data"]["createUpdateOdometer"]["id"]
  end

  def query(params)
    <<~GQL
    mutation createUpdateOdometer {
      createUpdateOdometer(input: {
        vehicleId: "#{params[:vehicle_id]}"
        originAddress: "#{params[:origin_address]}"
        destinationAddress: "#{params[:destination_address]}"
        distance: #{params[:distance]}
        duration: #{params[:duration]}
        city: "#{params[:city]}"
        withinRadius: #{params[:within_radius]}
      }){
        id
      }
    }
    GQL
  end
end

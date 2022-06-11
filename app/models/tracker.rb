class Tracker < ApplicationRecord
  # callbacks
  after_create :address_by_coordinates

  # validations
  validates :latitude, :longitude, presence: true

  private

  # Geocoding
  def address_by_coordinates
    data = Geocoder.search([current_tracker.latitude,current_tracker.longitude]).first.data
    current_tracker.update(update_address(data))
  end

  def update_address(data)
    {
      address: data["address"],
      display_name: data["display_name"],
    }
  end

  # GQL createUpdateOdometer
  # If Distance API pass and Odometer is created, then should leave boolean flag true on a records.
  # def create_odometer
  #   # Get last 4 Trackers and check that none been called to Distance API
  #   trackers = Tracker.where(vehicle_id: self.vehicle_id).order("created_at ASC").last(4).map{|tracker| tracker unless tracker.distance_api}.compact
  #
  #   if trackers.count == 4
  #     distance = request_distance_api(trackers)
  #     distance.build_response
  #     Rollbar.log("error", "#{distance.errors}") if distance.errors.present?
  #
  #     if distance.result.present?
  #       odometer = request_odometer(odometer_params(distance.result))
  #       odometer.build_response
  #       Rollbar.log("error", "Could not create an odometer: #{odometer.errors}") if odometer.errors.present?
  #
  #       trackers.each{ |tracker| tracker.update(distance_api: true) } if odometer.result.present?
  #     end
  #   end
  # end

  # def request_odometer(params)
  #   Vehicles::CreateUpdateOdometer.new(params)
  # end
  #
  # def request_distance_api(trackers)
  #   GoogleMaps::Distance.new(origins_coordinates(trackers), destinations_coordinates(trackers))
  # end

  # createUpdateOdometer payload
  # def odometer_params(params)
  #   {
  #     vehicle_id: self.vehicle_id,
  #     origin_address: params["origin_addresses"].first,
  #     destination_address: params["destination_addresses"].first,
  #     duration: params["rows"][0]["elements"][0]["duration"]["value"],
  #     distance: params["rows"][0]["elements"][0]["distance"]["value"],
  #     city: current_tracker.city,
  #     within_radius: current_tracker.within_radius
  #   }
  # end

  # Distance API payload
  # def origins_coordinates(trackers)
  #   { latitude: trackers.first[:latitude], longitude: trackers.first[:longitude] }
  # end
  #
  # # Distance API payload
  # def destinations_coordinates(trackers)
  #   { latitude: trackers.last[:latitude], longitude: trackers.last[:longitude] }
  # end

  def current_tracker
    Tracker.find(self.id)
  end
end

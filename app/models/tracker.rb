class Tracker < ApplicationRecord
  # callbacks
  after_create :within_city_radius?, :create_odometer

  # geocode
  reverse_geocoded_by :latitude, :longitude

  # validations
  validates :latitude, :longitude, presence: true

  private

  # Geocoding
  # Tracker get updated if coordinates are within city radius.
  def within_city_radius?
    tracker = Tracker.where(id: self.id)

    location_radiuses.each do |location_radius|
      within_radius = tracker.near([location_radius[:radius_latitude], location_radius[:radius_longitude]], location_radius[:radius_size], units: :km)
      tracker.update(update_tracker(location_radius)) if within_radius.present?
    end
  end

  def update_tracker(location_radius)
    {
      within_radius: true,
      city: location_radius[:city],
      radius_size: location_radius[:radius_size],
      radius_longitude: location_radius[:radius_longitude],
      radius_latitude: location_radius[:radius_latitude]
    }
  end

  # Radius size data: https://www.mapdevelopers.com/draw-circle-tool.php
  def location_radiuses
    [
      { city: "Vilnius", radius_size: 10, radius_latitude: 54.687046, radius_longitude: 25.282911}
    ]
  end


  # ----------- #


  # Distance API and createUpdateOdometer
  # If Distance API pass and Odometer is created, then should leave boolean flag true on a records.
  def create_odometer
    # Get last 4 Trackers and check that none been called to Distance API
    trackers = Tracker.where(vehicle_id: self.vehicle_id).order("created_at ASC").last(4).map{|tracker| tracker unless tracker.distance_api}.compact

    if trackers.count == 4
      distance = request_distance_api(trackers)
      distance.build_response
      Rollbar.log("error", "#{distance.errors}") if distance.errors.present?

      if distance.result.present?
        odometer = request_odometer(odometer_params(distance.result))
        odometer.build_response
        Rollbar.log("error", "Could not create an odometer: #{odometer.errors}") if odometer.errors.present?

        trackers.each{ |tracker| tracker.update(distance_api: true) } if odometer.result.present?
      end
    end
  end

  def request_odometer(params)
    Vehicles::CreateUpdateOdometer.new(params)
  end

  def request_distance_api(trackers)
    GoogleMaps::Distance.new(origins_coordinates(trackers), destinations_coordinates(trackers))
  end

  # createUpdateOdometer payload
  def odometer_params(params)
    {
      vehicle_id: self.vehicle_id,
      origin_address: params["origin_addresses"].first,
      destination_address: params["destination_addresses"].first,
      duration: params["rows"][0]["elements"][0]["duration"]["value"],
      distance: params["rows"][0]["elements"][0]["distance"]["value"],
      city: current_tracker.city,
      within_radius: current_tracker.within_radius
    }
  end

  # Distance API payload
  def origins_coordinates(trackers)
    { latitude: trackers.first[:latitude], longitude: trackers.first[:longitude] }
  end

  # Distance API payload
  def destinations_coordinates(trackers)
    { latitude: trackers.last[:latitude], longitude: trackers.last[:longitude] }
  end

  def current_tracker
    Tracker.find(self.id)
  end
end

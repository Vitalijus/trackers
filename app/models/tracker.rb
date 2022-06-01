class Tracker < ApplicationRecord
  # callbacks
  after_create :within_city_radius?

  # geocode
  reverse_geocoded_by :latitude, :longitude

  # validations
  validates :latitude, :longitude, presence: true

  private

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
end

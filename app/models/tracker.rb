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

  def current_tracker
    Tracker.find(self.id)
  end
end

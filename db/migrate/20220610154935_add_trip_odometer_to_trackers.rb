class AddTripOdometerToTrackers < ActiveRecord::Migration[6.1]
  def change
    add_column :trackers, :trip_odometer, :integer
  end
end

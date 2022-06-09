class AddImeiAndTotalOdometerAndTrackerDateTimeToTrackers < ActiveRecord::Migration[6.1]
  def change
    add_column :trackers, :imei, :string
    add_column :trackers, :total_odometer, :integer
    add_column :trackers, :date_time, :datetime
  end
end

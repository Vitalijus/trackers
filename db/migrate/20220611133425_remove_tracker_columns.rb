class RemoveTrackerColumns < ActiveRecord::Migration[6.1]
  def change
    remove_column :trackers, :within_radius
    remove_column :trackers, :city
    remove_column :trackers, :radius_size
    remove_column :trackers, :radius_longitude
    remove_column :trackers, :radius_latitude
    remove_column :trackers, :distance_api
  end
end

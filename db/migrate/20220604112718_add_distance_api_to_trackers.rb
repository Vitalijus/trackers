class AddDistanceApiToTrackers < ActiveRecord::Migration[6.1]
  def change
    add_column :trackers, :distance_api, :boolean, default: false
  end
end

class CreateTracker < ActiveRecord::Migration[6.1]
  def change
    create_table :trackers, id: :uuid do |t|
      t.float :latitude
      t.float :longitude
      t.string :speed
      t.uuid :vehicle_id

      t.timestamps
    end
  end
end

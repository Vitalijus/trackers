class CreateTracker < ActiveRecord::Migration[6.1]
  def change
    create_table :tracker, id: :uuid do |t|
      t.float :latitude
      t.float :longitude
      t.string :speed
      t.uuid :vehicle_id
      t.boolean :within_radius
      t.string :city
      t.integer :radius_size
      t.float :radius_longitude
      t.float :radius_latitude

      t.timestamps
    end
  end
end

module Types
  class TotalTrackersOdometerType < Types::BaseObject
    graphql_name "TotalTrackersOdometer"

    field :vehicle_id, String, null: true
    field :imei, String, null: true
    field :total_tracker_odometer, Int, null: true
  end
end

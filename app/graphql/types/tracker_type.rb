module Types
  class TrackerType < Types::BaseObject
    graphql_name "TrackerType"

    field :id, ID, null: false
    field :vehicle_id, ID, null: true
    field :latitude, Float, null: true
    field :longitude, Float, null: true
    field :speed, Int, null: true
    field :within_radius, Boolean, null: true
    field :city, String, null: true
    field :radius_size, Int, null: true
    field :radius_longitude, Float, null: true
    field :radius_latitude, Float, null: true
    field :created_at, String, null: true
    field :updated_at, String, null: true
  end
end

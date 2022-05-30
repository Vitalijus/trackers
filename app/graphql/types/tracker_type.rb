module Types
  class TrackerType < Types::BaseObject
    graphql_name "TrackerType"

    field :latitude, Float, null: false
    field :longitude, Float, null: false
  end
end

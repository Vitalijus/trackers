module Types
  class StatsType < Types::BaseObject
    graphql_name "StatsType"

    field :total_odometer, Int, null: true
    field :trip_odometer, Int, null: true
    field :count_records, Int, null: true
    field :city, String, null: true
  end
end

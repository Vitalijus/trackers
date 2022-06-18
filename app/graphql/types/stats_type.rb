module Types
  class StatsType < Types::BaseObject
    graphql_name "StatsType"

    field :vehicle_id, String, null: true
    field :total_vehicle_odometer, Int, null: true
    field :count_records, Int, null: true
    field :cities, GraphQL::Types::JSON, null: true
    field :elderships, GraphQL::Types::JSON, null: true
  end
end

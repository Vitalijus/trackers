module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Trackers
    field :trackers_by_vehicle_ids, resolver: Queries::Trackers::TrackersByVehicleIds
  end
end

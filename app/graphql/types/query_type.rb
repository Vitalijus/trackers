module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Trackers
    field :trackers_by_minutes_ago, resolver: Queries::Trackers::TrackersByMinutesAgo
  end
end

module Queries
  module Trackers
    class GetTrackers < Queries::BaseQuery
      graphql_name "GetTrackers"
      description "Find all Trackers"

      type [Types::TrackerType], null: true

      def resolve
        trackers = Tracker.all
        trackers
      end
    end
  end
end

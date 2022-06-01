module Queries
  module Trackers
    class TrackersByMinutesAgo < Queries::BaseQuery
      graphql_name "TrackersByMinutesAgo"
      description "Trackers by minutes ago"

      argument :minutes_ago, Int, required: true
      type [Types::TrackerType], null: true

      def resolve(args)
        Tracker.where("created_at > ?", args[:minutes_ago].minute.ago).order("created_at DESC")
      end
    end
  end
end

module Queries
  module Trackers
    class TrackersByVehicleIds < Queries::BaseQuery
      graphql_name "TrackersByVehicleIds"
      description "Trackers by vehicle_ids"

      argument :vehicle_id, [String], required: true
      type [Types::TrackerType], null: true

      def resolve(args)
        trackers = Tracker.where(vehicle_id: args[:vehicle_id])
        trackers
      end
    end
  end
end

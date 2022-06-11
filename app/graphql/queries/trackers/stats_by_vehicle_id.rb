module Queries
  module Trackers
    class StatsByVehicleId < Queries::BaseQuery
      graphql_name "StatsByVehicleId"
      description "Stats by vehicle id."

      argument :vehicle_id, ID, required: true
      type Types::StatsType, null: true

      def resolve(args)
        trackers = Tracker.where(vehicle_id: args[:vehicle_id]).order("date_time ASC")

        {
          total_odometer: total_odometer(trackers),
          trip_odometer: trip_odometer(trackers),
          city: city(trackers),
          count_records: trackers.count
        }
      end

      def total_odometer(trackers)
        trackers.max_by{|tracker| tracker[:total_odometer] }[:total_odometer]
      end

      def trip_odometer(trackers)
        trackers.sum {|tracker| tracker[:trip_odometer] }
      end

      def city(trackers)
        binding.pry
        cities = trackers.map{|tracker| {suburb: tracker["address"]["suburb"], trip_odometer: tracker["trip_odometer"], address: tracker["display_name"]}}
        cities = trackers.map{|tracker| tracker["address"]["city"]}

        cities.uniq
      end
    end
  end
end

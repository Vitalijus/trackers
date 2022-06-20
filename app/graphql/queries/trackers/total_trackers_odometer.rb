module Queries
  module Trackers
    class TotalTrackersOdometer < Queries::BaseQuery
      graphql_name "TotalTrackersOdometer"
      description "Get multiple total trackers odometer."

      argument :input, [GraphQL::Types::JSON], required: true
      type [Types::TotalTrackersOdometerType], null: true

      def resolve(args)
        total_trackers_odometer_list = []

        args[:input].each do |vehicle|
          trackers = Tracker.where(vehicle_id: vehicle["vehicleId"], imei: vehicle["imei"])
          total_trackers_odometer_list << build_tracker_data(vehicle["vehicleId"], vehicle["imei"], trackers)
        end

        total_trackers_odometer_list
      end

      def build_tracker_data(vehicle_id, imei, trackers)
        {
          vehicle_id: vehicle_id,
          imei: imei,
          total_tracker_odometer: total_tracker_odometer(trackers)
        }
      end

      def total_tracker_odometer(trackers)
        trackers.max_by{|tracker| tracker[:total_odometer]}[:total_odometer]
      end
    end
  end
end

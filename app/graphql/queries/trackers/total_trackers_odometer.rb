# query totalTrackersOdometer {
#   totalTrackersOdometer(
#   	input: ["76d7d529-02f6-47ae-877f-98f234cd990a, 357544374597827", "547a9ca8-03c3-40dc-9ba1-9939e10314da, 357544379627306"]
#   ){
#     vehicleId
#     imei
#     totalTrackerOdometer
#   }
# }

module Queries
  module Trackers
    class TotalTrackersOdometer < Queries::BaseQuery
      graphql_name "TotalTrackersOdometer"
      description "Get multiple total trackers odometer."

      argument :input, [String], required: true
      type [Types::TotalTrackersOdometerType], null: true

      def resolve(args)
        total_trackers_odometer_list = []

        args[:input].each do |vehicle|
          vehicle_id = vehicle.split(", ")[0]
          imei = vehicle.split(", ")[1]
          trackers = Tracker.where(vehicle_id: vehicle_id, imei: imei)

          total_trackers_odometer_list << build_tracker_data(vehicle_id, imei, trackers)
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
        return 0 if trackers.empty?
        trackers.max_by{|tracker| tracker[:total_odometer]}[:total_odometer]
      end
    end
  end
end

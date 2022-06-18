module Queries
  module Trackers
    class StatsByVehiclesId < Queries::BaseQuery
      graphql_name "StatsByVehiclesId"
      description "Stats by vehicles id."

      argument :vehicle_id, [ID], required: true
      type [Types::StatsType], null: true

      def resolve(args)
        trackers_list = []

        args[:vehicle_id].each do |vehicle_id|
          trackers = Tracker.where(vehicle_id: vehicle_id).order("date_time ASC")
          cities = cities(trackers)
          elderships = elderships(trackers)

          trackers_list << build_tracker_data(vehicle_id, cities, elderships, trackers)
        end

        trackers_list
      end

      def build_tracker_data(vehicle_id, cities, elderships, trackers)
        {
          vehicle_id: vehicle_id,
          total_vehicle_odometer: trip_odometer(trackers),
          cities: cities,
          elderships: elderships,
          count_records: trackers.count
        }
      end

      def trip_odometer(trackers)
        trackers.sum {|tracker| tracker[:trip_odometer] }
      end

      def cities(trackers)
        cities = trackers.map{|tracker| {city: tracker["address"]["city"], town: tracker["address"]["town"], percentage: nil, odometer: nil}}.uniq

        cities.each do |city|
          # City
          if city[:city].present?
            city[:odometer] = trackers.where("address ->> 'city' = '#{city[:city]}'").map{|city| city[:trip_odometer]}.sum
            city[:percentage] = odometer_percentage(total_trip_odometer(trackers), city[:odometer])
          end

          # Town
          if city[:town].present?
            city[:odometer] = trackers.where("address ->> 'town' = '#{city[:town]}'").map{|city| city[:trip_odometer]}.sum
            city[:percentage] = odometer_percentage(total_trip_odometer(trackers), city[:odometer])
          end
        end

        # Neither city or town
        cities.each do |city|
          if city[:city].nil? && city[:town].nil?
            city[:odometer] = total_trip_odometer(trackers) - total_items_odometer(cities)
            city[:percentage] = odometer_percentage(total_trip_odometer(trackers), city[:odometer])
          end
        end

        cities
      end

      def elderships(trackers)
        elderships = trackers.map{|tracker| {eldership: tracker["address"]["suburb"], percentage: nil, odometer: nil}}.uniq

        # Elderships
        elderships.each do |eldership|
          if eldership[:eldership].present?
            eldership[:odometer] = trackers.where("address ->> 'suburb' = '#{eldership[:eldership]}'").map{|eldership| eldership[:trip_odometer]}.sum
            eldership[:percentage] = odometer_percentage(total_trip_odometer(trackers), eldership[:odometer].to_f)
          end
        end

        # Unknown elderships
        elderships.each do |eldership|
          if eldership[:eldership].nil?
            eldership[:odometer] = total_trip_odometer(trackers) - total_items_odometer(elderships)
            eldership[:percentage] = odometer_percentage(total_trip_odometer(trackers), eldership[:odometer].to_f)
          end
        end

        elderships
      end

      def total_trip_odometer(trackers)
        trackers.sum {|tracker| tracker[:trip_odometer] }
      end

      def total_items_odometer(items)
        items.map{ |item| item[:odometer] }.compact.sum
      end

      def odometer_percentage(total_trip_odometer, item_odometer)
        (item_odometer.to_f / total_trip_odometer) * 100
      end
    end
  end
end

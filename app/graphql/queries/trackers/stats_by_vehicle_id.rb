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
        # cities = trackers.map{|tracker| tracker["address"]["city"] }.uniq
        # towns = trackers.map{|tracker| tracker["address"]["town"] }.uniq
        # city_town_list = (cities.uniq << towns.uniq).flatten.compact

        cities = trackers.map{|tracker| {city: tracker["address"]["city"], town: tracker["address"]["town"], distance: nil}}.uniq

        cities.each do |city|
          if city[:city].present?
            city[:distance] = Tracker.where("address ->> 'city' = '#{city[:city]}'").map{|city| city[:trip_odometer]}.sum
          elsif city[:town].present?
            city[:distance] = Tracker.where("address ->> 'town' = '#{city[:town]}'").map{|city| city[:trip_odometer]}.sum
          end
        end

        total = []
        cities.each do |city|
          total << city[:distance]
        end

        total_cities_distance = total.compact.sum
        trip_odometer = trackers.sum {|tracker| tracker[:trip_odometer] }
        outside_city_distance = trip_odometer - total_cities_distance

        cities.each do |city|
          if city[:city].nil? && city[:town].nil?
            city[:distance] = outside_city_distance
          end
        end

        # cities = trackers.map{|tracker| {city: tracker["address"]["city"], town: tracker["address"]["town"], distance: []}}.uniq

        # cities.each do |city|
        #   trackers.each do |tracker|
        #     city[:distance] << tracker["trip_odometer"] if city[:city] == tracker["address"]["city"]
        #     city[:distance] << tracker["trip_odometer"] if city[:town] == tracker["address"]["town"]
        #   end
        # end
        #
        # cities.map{|city| { city: city[:city], town: city[:town], distance: city[:distance].sum }}

        # r = cities.each do |city|
        #   trackers.each do |tracker|
        #     if city[:city] == tracker["address"]["city"]
        #       city[:distance] << tracker["trip_odometer"]
        #     elsif city[:town] == tracker["address"]["town"]
        #       city[:distance] << tracker["trip_odometer"]
        #     else
        #       city[:distance] << tracker["trip_odometer"]
        #     end
        #   end
        # end
        #
        # cities.map{|city| {city: city[:city], town: city[:town], distance: city[:distance].sum} }
        # cities.uniq.compact.map{|city| { city: city, distance: 0 }}
        # city_town_list = (cities.uniq << towns.uniq).flatten.compact

        # trackers.where()
        # trackers.map do |tracker|
        #   { id: tracker[:id], start: tracker[:start] }
        # end

        with_distance = trackers.map{ |tracker| { city: tracker["address"]["city"], town: tracker["address"]["town"], distance: tracker["trip_odometer"] } }

        city_distance = []
        city_town_list.each do |city|
          trackers.each do |tracker|
            if city == tracker["address"]["city"] || city == tracker["address"]["town"]
              city_distance <<
          end
        end
      end
    end
  end
end

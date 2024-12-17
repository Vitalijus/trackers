class DataTracker
  attr_accessor :tracker_data

  def initialize(tracker_data)
    @tracker_data = tracker_data
  end

  def create_tracker
    @tracker_data.each do |tracker|
      if tracker_valid?(tracker)
        io_data = io_data(tracker)
        vehicle = Vehicles::VehicleByImei.new(tracker[:imei].to_s)
        vehicle.build_response

        Rollbar.log("error", "#{vehicle.errors}") if vehicle.errors.present?
        Tracker.create(build_tracker(tracker, io_data, vehicle.result)) if vehicle.result.present?
      end
    end
  end

  # Check if gps data is above certain level
  def tracker_valid?(tracker)
    tracker[:gps_data][:latitude] != 0.0 &&
      tracker[:gps_data][:longitude] != 0.0 &&
      tracker[:gps_data][:speed] > 5
  end

  # IO data collection.
  def io_data(tracker)
    io_hash = {}

    tracker[:io_data].each do |k,v|
      io_hash[:total_odometer] = v if k == 16 # IO Total odometer
      io_hash[:trip_odometer] = v if k == 199 # IO Trip odometer
    end

    io_hash
  end

  # Tracker model data
  def build_tracker(tracker, io_data, vehicle_id)
    {
      imei: tracker[:imei],
      longitude: tracker[:gps_data][:longitude],
      latitude: tracker[:gps_data][:latitude],
      speed: tracker[:gps_data][:speed],
      total_odometer: io_data[:total_odometer],
      trip_odometer: io_data[:trip_odometer],
      date_time: tracker[:date_time],
      vehicle_id: vehicle_id
    }
  end
end

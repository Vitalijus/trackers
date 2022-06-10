# Teltonika module configurations:
# https://teltonika-gps.com/product/fmt100/

# Setup Teltonika Configurator GPRS
# APN name: internet.life.com.by | domain: 52.12.75.4 (AWS Public IP) | port:65432 (AWS Security group PORT)
# APN name: iot.truphone.com     | domain: 52.12.75.4 (AWS Public IP) | port:65432 (AWS Security group PORT)

# How to keep server running on EC2 in the background (screen mode)?
# screen rails server -b 0.0.0.0 to start rails server.
# CTRL + A + D from terminal to detached the existing process and let it run.
# Type screen -r, then "screen -d -r [pid.]tty.host" to resume detached process.

# Start rails server on EC2 and open GraphQL UI
# rails server -b 0.0.0.0, to start in screen mode: screen rails server -b 0.0.0.0
# http://34.209.247.30:3000/graphiql (AWS Public IP), GQL playground.

# To start socketing.rake file run below:
# rake socketing:start, to start in screen mode: screen rake socketing:start

# How to add ENV var?
# Connect to EC2 and open file with vim ~/.bash_profile
# Add ENV var: export GOOGLE_MAP_API=0000 and close file.
# Provision new ENV with: source ~/.bash_profile, open rails c and run ENV["GOOGLE_MAP_API"]

# HOW IT WORKS?
# Teltonika module communicating with the server. First time module is authenticated by IMEI,
# second time data from module decoded and confirmation about number_of_rec is sent back to the module.
# Positive response is sent, if decoded num_of_rec matching with what
# module has send, then communication is over. Otherwise if decoded
# num_of_rec not matching with module's, then module will send data again
# Module is sending data packets every 2min.
# When num_of_rec matching Tracker data, like latitude, longitude, speed is being saved to the DB.

namespace :socketing do
  desc "Start TCP server"
  task start: :environment do
    require 'socket'
    require 'date'

    class Decoder
      def initialize(payload, imei)
        @payload = payload
        @imei = imei
        @precision = 10000000.0
      end

      def number_of_rec
        @payload[18..19].to_i(16)
      end

      def number_of_total_rec
        @payload[-10..-9].to_i(16)
      end

      def avl_data
        @payload[20..-9]
      end

      def timestamp(avl_data, position)
        timestamp_hex = avl_data[position..position+15]
        timestamp_decode = timestamp_hex.to_i(16)
        DateTime.strptime(timestamp_decode.to_s, '%Q').strftime('%FT%T')
      end

      def priority(avl_data, position)
        priority_hex = avl_data[position..position+1]
        priority_hex.to_i(16)
      end

      def longitude(avl_data, position)
        longitude_hex = avl_data[position..position+7]
        longitude_decode = longitude_hex.to_i(16)
        longitude_decode / @precision
      end

      def latitude(avl_data, position)
        latitude_hex = avl_data[position..position+7]
        latitude_decode = latitude_hex.to_i(16)
        latitude_decode / @precision
      end

      def altitude(avl_data, position)
        altitude_hex = avl_data[position..position+3]
        altitude_hex.to_i(16)
      end

      def angle(avl_data, position)
        angle_hex = avl_data[position..position+3]
        angle_hex.to_i(16)
      end

      def satellites(avl_data, position)
        satellites_hex = avl_data[position..position+1]
        satellites_hex.to_i(16)
      end

      def speed(avl_data, position)
        speed_hex = avl_data[position..position+3]
        speed_hex.to_i(16)
      end

      def io_event_code(avl_data, position)
        avl_data[position..position + 1].to_i(16)
      end

      def number_of_io_elements(avl_data, position)
        avl_data[position..position + 1].to_i(16)
      end

      def decode
        data = []

        if number_of_rec == number_of_total_rec
          index = 0
          position = 0

          while index < number_of_rec
            # Timestamp
            timestamp = timestamp(avl_data, position)
            position += 16

            # Priority
            priority = priority(avl_data, position)
            position += 2

            # Longitude
            longitude = longitude(avl_data, position)
            position += 8

            # Latitude
            latitude = latitude(avl_data, position)
            position += 8

            # Altitude
            altitude = altitude(avl_data, position)
            position += 4

            # Angle
            angle = angle(avl_data, position)
            position += 4

            # Satellites
            satellites = satellites(avl_data, position)
            position += 2

            # Speed
            speed = speed(avl_data, position)
            position += 4

            # SensorsData

            # IO element ID of Event generated
            io_event_code = avl_data[position..position + 1].to_i(16)
            position += 2

            number_of_io_elements = avl_data[position..position + 1].to_i(16)
            position += 2

            # 1 Bit
            number_of_io1_bit_elements = avl_data[position..position + 1].to_i(16)
            position += 2
            io_data = {}
            number_of_io1_bit_elements.times do
              io_code = avl_data[position..position + 1].to_i(16)
              position += 2
              io_val = avl_data[position..position + 1].to_i(16)
              position += 2
              io_data[io_code] = io_val
            end

            # 2 Bit
            number_of_io2_bit_elements = avl_data[position..position + 1].to_i(16)
            position += 2

            number_of_io2_bit_elements.times do
              io_code = avl_data[position..position + 1].to_i(16)
              position += 2
              io_val = avl_data[position..position + 3].to_i(16)
              position += 4
              io_data[io_code] = io_val
            end

            # 4 Bit
            number_of_io4_bit_elements = avl_data[position..position + 1].to_i(16)
            position += 2

            number_of_io4_bit_elements.times do
              io_code = avl_data[position..position + 1].to_i(16)
              position += 2
              io_val = avl_data[position..position + 7].to_i(16)
              position += 8
              io_data[io_code] = io_val
            end

            # 8 Bit
            number_of_io8_bit_elements = avl_data[position..position + 1].to_i(16)
            position += 2

            number_of_io8_bit_elements.times do
              io_code = avl_data[position..position + 1].to_i(16)
              position += 2
              io_val = avl_data[position..position + 15].to_i(16)
              position += 16
              io_data[io_code] = io_val
            end

            index += 1

            decoded_data = {
              imei: @imei,
              number_of_rec: number_of_rec,
              date_time: timestamp,
              priority: priority,
              gps_data: {
                  longitude: longitude,
                  latitude: latitude,
                  altitude: altitude,
                  angle: angle,
                  satellites: satellites,
                  speed: speed,
              },
              io_event_code: io_event_code,
              number_of_io_elements: number_of_io_elements,
              io_data: io_data
            }

            data << decoded_data
          end
        end

        return data
      end
    end

    class ClientThread
      def initialize(port)
        @server = TCPServer.open(port)
        @imei = "unknown"
      end

      def log(msg)
        "#{Time.now.utc.strftime('%FT%T')} #{msg}"
      end

      def run
        p self.log("Started TCP Server")

        loop do # loop is neede to run multiple Threads in parallel
          Thread.start(@server.accept) do |client|
            if client
              2.times do |index| # Start communication with module, first time device is authenticated,
                begin            # second data decoded and confirmation about number_of_rec is sent to module.
                  buff = client.recv(8192)
                  length, imei = buff.unpack("Sa*")
                  data = buff.unpack("H*").first

                  if index == 0 # First step in communication with module
                    @imei = imei # save module imei
                    p self.log("Device Authenticated | IMEI: #{@imei}")
                    client.send([0x01].pack("C"), 0) # send response to module
                  elsif index == 1 # Second step in communication with module
                    decoder = Decoder.new(data, @imei) # Decode data
                    Rollbar.log("error", "FMT100 data decoding error: #{decoder}") if !decoder.present?
                    num_of_rec = decoder.number_of_rec # get number_of_rec

                    if num_of_rec == 0
                      client.send([0x00].pack("C"), 0) # send negative response to module
                      client.close # close communication
                    else
                      p decoder.decode
                      client.send([num_of_rec].pack("L>"), 0) # send positive response, if decoded num_of_rec matching with what
                      p self.log("Done! Closing Connection")  # module has send, then communication is over. Otherwise if decoded
                      client.close                            # num_of_rec not matching with module's, then module will send data again.

                      create_tracker(decoder.decode) # Create Tracker
                    end
                  else
                    client.send([0x00].pack("C"), 0) # send negative response to module
                  end

                rescue SocketError
                  p self.log("Socket has failed")
                  Rollbar.log("error", "Socket has failed")
                end
              end # end of loop twice

            else
              p self.log('Socket is null')
              Rollbar.log("error", "Socket is null")
            end # if conditional
          end # end of Thread
        end # end of infinite loop
      end # run method

      # Tracker model
      def create_tracker(tracker_data)
        tracker_data.each do |tracker|
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
          tracker[:gps_data][:speed] > 7
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
    end # end of class

    new_thread = ClientThread.new(65432)
    p new_thread.run

    # To test Tracker creation locally use below data
    #
    # new_thread = ClientThread.new
    # tracker_data = [
    #   {:imei=>"357544374597827", :number_of_rec=>2, :date_time=>"2022-01-10T19:03:49", :priority=>0, :gps_data=>{:longitude=>27.53355, :latitude=>53.9341616, :altitude=>0, :angle=>0, :satellites=>0, :speed=>10}, :io_event_code=>0, :number_of_io_elements=>12, :io_data=>{239=>0, 240=>0, 21=>5, 200=>0, 69=>2, 181=>0, 182=>0, 66=>0, 67=>3953, 68=>0, 241=>25704, 16=>707167}},
    #   {:imei=>"357544374597827", :number_of_rec=>2, :date_time=>"2022-01-10T19:03:51", :priority=>0, :gps_data=>{:longitude=>27.53355, :latitude=>53.9341616, :altitude=>0, :angle=>0, :satellites=>0, :speed=>22}, :io_event_code=>240, :number_of_io_elements=>12, :io_data=>{239=>0, 240=>1, 21=>5, 200=>0, 69=>2, 181=>0, 182=>0, 66=>0, 67=>3949, 68=>0, 241=>25704, 16=>707167}},
    #   {:imei=>"357544374597827", :number_of_rec=>2, :date_time=>"2022-01-10T19:03:51", :priority=>0, :gps_data=>{:longitude=>0.0, :latitude=>0.0, :altitude=>0, :angle=>0, :satellites=>0, :speed=>0}, :io_event_code=>240, :number_of_io_elements=>12, :io_data=>{239=>0, 240=>1, 21=>5, 200=>0, 69=>2, 181=>0, 182=>0, 66=>0, 67=>3949, 68=>0, 241=>25704, 16=>707167}}
    # ]
    # p new_thread.create_tracker(tracker_data)
  end
end

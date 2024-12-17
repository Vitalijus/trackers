class DataDecoder
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

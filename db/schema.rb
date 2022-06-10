# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_06_10_154935) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "trackers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.float "latitude"
    t.float "longitude"
    t.string "speed"
    t.uuid "vehicle_id"
    t.boolean "within_radius"
    t.string "city"
    t.integer "radius_size"
    t.float "radius_longitude"
    t.float "radius_latitude"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "distance_api", default: false
    t.string "imei"
    t.integer "total_odometer"
    t.datetime "date_time"
    t.integer "trip_odometer"
  end

end

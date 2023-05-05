# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_05_04_185426) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "appointments", force: :cascade do |t|
    t.bigint "office_id"
    t.bigint "prosecutor_id", null: false
    t.integer "genpro_gov_sk_prosecutors_list_id"
    t.datetime "started_at", null: false
    t.datetime "ended_at"
    t.integer "type", null: false
    t.string "place"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["genpro_gov_sk_prosecutors_list_id"], name: "index_appointments_on_genpro_gov_sk_prosecutors_list_id"
    t.index ["office_id"], name: "index_appointments_on_office_id"
    t.index ["prosecutor_id"], name: "index_appointments_on_prosecutor_id"
  end

  create_table "decrees", force: :cascade do |t|
    t.bigint "genpro_gov_sk_decree_id", null: false
    t.bigint "office_id"
    t.bigint "prosecutor_id"
    t.string "url", null: false
    t.string "number", null: false
    t.string "file_info", null: false
    t.integer "file_type", null: false
    t.date "effective_on", null: false
    t.date "published_on", null: false
    t.string "file_number", null: false
    t.string "resolution", null: false
    t.string "means_of_resolution"
    t.text "text", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["effective_on"], name: "index_decrees_on_effective_on"
    t.index ["genpro_gov_sk_decree_id"], name: "index_decrees_on_genpro_gov_sk_decree_id"
    t.index ["office_id"], name: "index_decrees_on_office_id"
    t.index ["prosecutor_id"], name: "index_decrees_on_prosecutor_id"
    t.index ["published_on"], name: "index_decrees_on_published_on"
    t.index ["url"], name: "index_decrees_on_url"
  end

  create_table "employees", force: :cascade do |t|
    t.bigint "office_id", null: false
    t.bigint "prosecutor_id"
    t.string "name", null: false
    t.jsonb "name_parts", null: false
    t.string "position", limit: 1024, null: false
    t.integer "rank", null: false
    t.string "phone"
    t.datetime "disabled_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "position"], name: "index_employees_on_name_and_position"
    t.index ["name"], name: "index_employees_on_name"
    t.index ["name_parts"], name: "index_employees_on_name_parts"
    t.index ["office_id", "disabled_at", "rank"], name: "index_employees_on_office_id_and_disabled_at_and_rank", unique: true, where: "(disabled_at IS NULL)"
    t.index ["office_id"], name: "index_employees_on_office_id"
    t.index ["position"], name: "index_employees_on_position"
    t.index ["prosecutor_id"], name: "index_employees_on_prosecutor_id"
    t.index ["rank"], name: "index_employees_on_rank"
  end

  create_table "genpro_gov_sk_decrees", force: :cascade do |t|
    t.jsonb "data", null: false
    t.binary "file", null: false
    t.string "digest", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["digest"], name: "index_genpro_gov_sk_decrees_on_digest", unique: true
  end

  create_table "genpro_gov_sk_offices", force: :cascade do |t|
    t.jsonb "data", null: false
    t.binary "file", null: false
    t.string "digest", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["digest"], name: "index_genpro_gov_sk_offices_on_digest", unique: true
  end

  create_table "genpro_gov_sk_prosecutors_lists", force: :cascade do |t|
    t.jsonb "data", null: false
    t.binary "file", null: false
    t.string "digest", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["digest"], name: "index_genpro_gov_sk_prosecutors_lists_on_digest", unique: true
  end

  create_table "offices", force: :cascade do |t|
    t.bigint "genpro_gov_sk_office_id"
    t.string "name", null: false
    t.integer "type"
    t.string "address", limit: 1024, null: false
    t.string "additional_address", limit: 1024
    t.string "zipcode", null: false
    t.string "city", null: false
    t.string "phone", null: false
    t.string "fax"
    t.string "email"
    t.string "electronic_registry"
    t.jsonb "registry", null: false
    t.float "latitude", null: false
    t.float "longitude", null: false
    t.datetime "destroyed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "news"
    t.index ["city"], name: "index_offices_on_city"
    t.index ["destroyed_at"], name: "index_offices_on_destroyed_at"
    t.index ["genpro_gov_sk_office_id"], name: "index_offices_on_genpro_gov_sk_office_id"
    t.index ["name"], name: "index_offices_on_name", unique: true
    t.index ["type"], name: "index_offices_on_type"
    t.index ["type"], name: "index_offices_on_unique_general_type", unique: true, where: "(type = 0)"
    t.index ["type"], name: "index_offices_on_unique_specialized_type", unique: true, where: "(type = 1)"
  end

  create_table "paragraphs", force: :cascade do |t|
    t.integer "type", null: false
    t.string "name", null: false
    t.string "value", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["type"], name: "index_paragraphs_on_type"
    t.index ["value"], name: "index_paragraphs_on_value", unique: true
  end

  create_table "prosecutors", force: :cascade do |t|
    t.integer "genpro_gov_sk_prosecutors_list_id"
    t.string "name", null: false
    t.jsonb "name_parts", null: false
    t.jsonb "declarations"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "news"
    t.jsonb "decrees", default: [], null: false
    t.index ["genpro_gov_sk_prosecutors_list_id"], name: "index_prosecutors_on_genpro_gov_sk_prosecutors_list_id"
    t.index ["name"], name: "index_prosecutors_on_name"
    t.index ["name_parts"], name: "index_prosecutors_on_name_parts"
  end

  create_table "statistics", force: :cascade do |t|
    t.bigint "office_id", null: false
    t.integer "year", null: false
    t.string "metric", null: false
    t.string "paragraph"
    t.integer "count", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["metric"], name: "index_statistics_on_metric"
    t.index ["office_id"], name: "index_statistics_on_office_id"
    t.index ["paragraph", "metric"], name: "index_statistics_on_paragraph_and_metric"
    t.index ["paragraph"], name: "index_statistics_on_paragraph"
    t.index ["year", "office_id", "metric", "paragraph"], name: "index_statistics_on_year_and_office_id_and_metric_and_paragraph", unique: true
    t.index ["year"], name: "index_statistics_on_year"
  end

  add_foreign_key "appointments", "genpro_gov_sk_prosecutors_lists"
  add_foreign_key "appointments", "offices"
  add_foreign_key "appointments", "prosecutors"
  add_foreign_key "decrees", "genpro_gov_sk_decrees"
  add_foreign_key "decrees", "offices"
  add_foreign_key "decrees", "prosecutors"
  add_foreign_key "employees", "offices"
  add_foreign_key "employees", "prosecutors"
  add_foreign_key "offices", "genpro_gov_sk_offices"
  add_foreign_key "prosecutors", "genpro_gov_sk_prosecutors_lists"
  add_foreign_key "statistics", "offices"
end

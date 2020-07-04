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

ActiveRecord::Schema.define(version: 2020_07_04_140315) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'pg_trgm'
  enable_extension 'plpgsql'
  enable_extension 'unaccent'

  create_table 'appointments', force: :cascade do |t|
    t.bigint 'office_id'
    t.bigint 'prosecutor_id', null: false
    t.bigint 'genpro_gov_sk_prosecutors_list_id', null: false
    t.datetime 'started_at', null: false
    t.datetime 'ended_at'
    t.integer 'type', null: false
    t.string 'place'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index %w[genpro_gov_sk_prosecutors_list_id], name: 'index_appointments_on_genpro_gov_sk_prosecutors_list_id'
    t.index %w[office_id], name: 'index_appointments_on_office_id'
    t.index %w[prosecutor_id], name: 'index_appointments_on_prosecutor_id'
  end

  create_table 'employees', force: :cascade do |t|
    t.bigint 'office_id', null: false
    t.bigint 'prosecutor_id'
    t.string 'name', null: false
    t.string 'position', limit: 1024, null: false
    t.integer 'rank', null: false
    t.string 'phone'
    t.datetime 'disabled_at'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index %w[name position], name: 'index_employees_on_name_and_position'
    t.index %w[office_id disabled_at rank],
            name: 'index_employees_on_office_id_and_disabled_at_and_rank', unique: true, where: '(disabled_at IS NULL)'
    t.index %w[office_id], name: 'index_employees_on_office_id'
    t.index %w[prosecutor_id], name: 'index_employees_on_prosecutor_id'
  end

  create_table 'genpro_gov_sk_offices', force: :cascade do |t|
    t.jsonb 'data', null: false
    t.binary 'file', null: false
    t.string 'digest', null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index %w[digest], name: 'index_genpro_gov_sk_offices_on_digest', unique: true
  end

  create_table 'genpro_gov_sk_prosecutors_lists', force: :cascade do |t|
    t.jsonb 'data', null: false
    t.binary 'file', null: false
    t.string 'digest', null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index %w[digest], name: 'index_genpro_gov_sk_prosecutors_lists_on_digest', unique: true
  end

  create_table 'offices', force: :cascade do |t|
    t.bigint 'genpro_gov_sk_office_id', null: false
    t.string 'name', null: false
    t.integer 'type'
    t.string 'address', limit: 1024, null: false
    t.string 'zipcode', null: false
    t.string 'city', null: false
    t.string 'phone', null: false
    t.string 'fax'
    t.string 'email'
    t.string 'electronic_registry'
    t.jsonb 'registry', null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index %w[genpro_gov_sk_office_id], name: 'index_offices_on_genpro_gov_sk_office_id'
    t.index %w[name], name: 'index_offices_on_name', unique: true
    t.index %w[type], name: 'index_offices_on_type'
    t.index %w[type], name: 'index_offices_on_unique_general_type', unique: true, where: '(type = 0)'
    t.index %w[type], name: 'index_offices_on_unique_specialized_type', unique: true, where: '(type = 1)'
  end

  create_table 'prosecutors', force: :cascade do |t|
    t.bigint 'genpro_gov_sk_prosecutors_list_id', null: false
    t.string 'name', null: false
    t.jsonb 'declarations'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index %w[genpro_gov_sk_prosecutors_list_id], name: 'index_prosecutors_on_genpro_gov_sk_prosecutors_list_id'
    t.index %w[name], name: 'index_prosecutors_on_name'
  end

  add_foreign_key 'appointments', 'genpro_gov_sk_prosecutors_lists'
  add_foreign_key 'appointments', 'offices'
  add_foreign_key 'appointments', 'prosecutors'
  add_foreign_key 'employees', 'offices'
  add_foreign_key 'employees', 'prosecutors'
  add_foreign_key 'offices', 'genpro_gov_sk_offices'
  add_foreign_key 'prosecutors', 'genpro_gov_sk_prosecutors_lists'
end

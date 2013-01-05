# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130105124006) do

  create_table "attacks", :force => true do |t|
    t.integer  "metal"
    t.integer  "crystal"
    t.integer  "deuterium"
    t.integer  "time"
    t.integer  "start_planet_id"
    t.integer  "target_planet_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "buildings", :force => true do |t|
    t.string   "keyword"
    t.string   "reg_exp"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "defenses", :force => true do |t|
    t.string   "keyword"
    t.string   "reg_exp"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "fleets", :force => true do |t|
    t.string   "keyword"
    t.string   "reg_exp"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "planets", :force => true do |t|
    t.integer  "galaxy"
    t.integer  "system"
    t.integer  "planet_number"
    t.integer  "user_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "planets", ["galaxy", "system", "planet_number"], :name => "index_planets_on_galaxy_and_system_and_planet_number"

  create_table "report_buildings", :force => true do |t|
    t.integer  "value"
    t.integer  "report_id"
    t.integer  "building_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "report_defenses", :force => true do |t|
    t.integer  "value"
    t.integer  "report_id"
    t.integer  "defense_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "report_fleets", :force => true do |t|
    t.integer  "value"
    t.integer  "report_id"
    t.integer  "fleet_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "report_researches", :force => true do |t|
    t.integer  "value"
    t.integer  "report_id"
    t.integer  "research_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "report_resources", :force => true do |t|
    t.integer  "value"
    t.integer  "report_id"
    t.integer  "resource_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "reports", :force => true do |t|
    t.datetime "time"
    t.integer  "planet_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.text     "message"
    t.boolean  "include_resources",  :default => false
    t.boolean  "include_researches", :default => false
    t.boolean  "include_buildings",  :default => false
    t.boolean  "include_fleets",     :default => false
    t.boolean  "include_defenses",   :default => false
    t.text     "report_text"
  end

  create_table "researches", :force => true do |t|
    t.string   "keyword"
    t.string   "reg_exp"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "resources", :force => true do |t|
    t.string   "keyword"
    t.string   "reg_exp"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "ogame_id"
    t.string   "password"
    t.datetime "last_login"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end

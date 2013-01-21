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

ActiveRecord::Schema.define(:version => 20130121010133) do

  create_table "attacks", :force => true do |t|
    t.integer  "metal"
    t.integer  "crystal"
    t.integer  "deuterium"
    t.datetime "time"
    t.integer  "start_planet_id"
    t.integer  "target_planet_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "attacks", ["start_planet_id"], :name => "attacks_start_planet_id_fk"
  add_index "attacks", ["target_planet_id"], :name => "attacks_target_planet_id_fk"

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
  add_index "planets", ["user_id"], :name => "planets_user_id_fk"

  create_table "report_buildings", :force => true do |t|
    t.integer  "value"
    t.integer  "report_id"
    t.integer  "building_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "report_buildings", ["building_id"], :name => "index_report_buildings_on_building_id"
  add_index "report_buildings", ["report_id"], :name => "index_report_buildings_on_report_id"

  create_table "report_defenses", :force => true do |t|
    t.integer  "value"
    t.integer  "report_id"
    t.integer  "defense_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "report_defenses", ["defense_id"], :name => "index_report_defenses_on_defense_id"
  add_index "report_defenses", ["report_id"], :name => "index_report_defenses_on_report_id"

  create_table "report_fleets", :force => true do |t|
    t.integer  "value"
    t.integer  "report_id"
    t.integer  "fleet_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "report_fleets", ["fleet_id"], :name => "index_report_fleets_on_fleet_id"
  add_index "report_fleets", ["report_id"], :name => "index_report_fleets_on_report_id"

  create_table "report_researches", :force => true do |t|
    t.integer  "value"
    t.integer  "report_id"
    t.integer  "research_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "report_researches", ["report_id"], :name => "index_report_researches_on_report_id"
  add_index "report_researches", ["research_id"], :name => "index_report_researches_on_research_id"

  create_table "report_resources", :force => true do |t|
    t.integer  "value"
    t.integer  "report_id"
    t.integer  "resource_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "report_resources", ["report_id"], :name => "index_report_resources_on_report_id"
  add_index "report_resources", ["resource_id"], :name => "index_report_resources_on_resource_id"

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

  add_index "reports", ["planet_id"], :name => "index_reports_on_planet_id"

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
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.string   "status",     :default => ""
  end

  add_foreign_key "attacks", "planets", :name => "attacks_start_planet_id_fk", :column => "start_planet_id", :dependent => :delete
  add_foreign_key "attacks", "planets", :name => "attacks_target_planet_id_fk", :column => "target_planet_id", :dependent => :delete

  add_foreign_key "planets", "users", :name => "planets_user_id_fk", :dependent => :delete

  add_foreign_key "report_buildings", "buildings", :name => "report_buildings_building_id_fk", :dependent => :delete
  add_foreign_key "report_buildings", "reports", :name => "report_buildings_report_id_fk", :dependent => :delete

  add_foreign_key "report_defenses", "defenses", :name => "report_defenses_defense_id_fk", :dependent => :delete
  add_foreign_key "report_defenses", "reports", :name => "report_defenses_report_id_fk", :dependent => :delete

  add_foreign_key "report_fleets", "fleets", :name => "report_fleets_fleet_id_fk", :dependent => :delete
  add_foreign_key "report_fleets", "reports", :name => "report_fleets_report_id_fk", :dependent => :delete

  add_foreign_key "report_researches", "reports", :name => "report_researches_report_id_fk", :dependent => :delete
  add_foreign_key "report_researches", "researches", :name => "report_researches_research_id_fk", :dependent => :delete

  add_foreign_key "report_resources", "reports", :name => "report_resources_report_id_fk", :dependent => :delete
  add_foreign_key "report_resources", "resources", :name => "report_resources_resource_id_fk", :dependent => :delete

  add_foreign_key "reports", "planets", :name => "reports_planet_id_fk", :dependent => :delete

end

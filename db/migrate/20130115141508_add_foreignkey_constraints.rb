class AddForeignkeyConstraints < ActiveRecord::Migration
  def change
    add_index :reports, :planet_id
    add_foreign_key :planets, :users, :dependent => :delete
    add_foreign_key :reports, :planets, :dependent => :delete

    ReportResource.find_each do |report_resource|
      unless report_resource.report
        report_resource.delete
      end
    end

    add_index :report_resources, :report_id
    add_index :report_resources, :resource_id
    add_foreign_key :report_resources, :reports, :dependent => :delete
    add_foreign_key :report_resources, :resources, :dependent => :delete

    ReportResearch.find_each do |report_research|
      unless report_research.report
        report_research.delete
      end
    end

    add_index :report_researches, :report_id
    add_index :report_researches, :research_id
    add_foreign_key :report_researches, :reports, :dependent => :delete
    add_foreign_key :report_researches, :researches, :dependent => :delete

    add_index :report_fleets, :report_id
    add_index :report_fleets, :fleet_id
    add_foreign_key :report_fleets, :reports, :dependent => :delete
    add_foreign_key :report_fleets, :fleets, :dependent => :delete

    add_index :report_defenses, :report_id
    add_index :report_defenses, :defense_id
    add_foreign_key :report_defenses, :reports, :dependent => :delete
    add_foreign_key :report_defenses, :defenses, :dependent => :delete

    ReportBuilding.find_each do |report_building|
      unless report_building.report
        report_building.delete
      end
    end

    add_index :report_buildings, :report_id
    add_index :report_buildings, :building_id
    add_foreign_key :report_buildings, :reports, :dependent => :delete
    add_foreign_key :report_buildings, :buildings, :dependent => :delete

    add_foreign_key :attacks, :planets, :column => :start_planet_id, :dependent => :delete
    add_foreign_key :attacks, :planets, :column => :target_planet_id, :dependent => :delete
  end
end

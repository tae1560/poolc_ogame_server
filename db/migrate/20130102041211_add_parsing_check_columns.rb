class AddParsingCheckColumns < ActiveRecord::Migration
  def change
    add_column :reports, :include_resources, :boolean, :default => 0
    add_column :reports, :include_researches, :boolean, :default => 0
    add_column :reports, :include_buildings, :boolean, :default => 0
    add_column :reports, :include_fleets, :boolean, :default => 0
    add_column :reports, :include_defenses, :boolean, :default => 0
  end
end

class CreateReportBuildings < ActiveRecord::Migration
  def change
    create_table :report_buildings do |t|
      t.integer :value
      t.integer :report_id
      t.integer :building_id

      t.timestamps
    end
  end
end

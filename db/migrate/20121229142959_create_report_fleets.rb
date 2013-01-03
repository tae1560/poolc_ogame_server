class CreateReportFleets < ActiveRecord::Migration
  def change
    create_table :report_fleets do |t|
      t.integer :value
      t.integer :report_id
      t.integer :fleet_id

      t.timestamps
    end
  end
end

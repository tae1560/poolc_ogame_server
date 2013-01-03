class CreateReportResources < ActiveRecord::Migration
  def change
    create_table :report_resources do |t|
      t.integer :value
      t.integer :report_id
      t.integer :resource_id

      t.timestamps
    end
  end
end

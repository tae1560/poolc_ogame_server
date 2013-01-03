class CreateReportResearches < ActiveRecord::Migration
  def change
    create_table :report_researches do |t|
      t.integer :value
      t.integer :report_id
      t.integer :research_id

      t.timestamps
    end
  end
end

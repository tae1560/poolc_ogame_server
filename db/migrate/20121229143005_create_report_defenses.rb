class CreateReportDefenses < ActiveRecord::Migration
  def change
    create_table :report_defenses do |t|
      t.integer :value
      t.integer :report_id
      t.integer :defense_id

      t.timestamps
    end
  end
end

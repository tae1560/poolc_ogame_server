class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.datetime :time
      t.integer :planet_id

      t.timestamps
    end
  end
end

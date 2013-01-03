class CreateAttacks < ActiveRecord::Migration
  def change
    create_table :attacks do |t|
      t.integer :metal
      t.integer :crystal
      t.integer :deuterium
      t.integer :time

      t.integer :start_planet_id, :index => true
      t.integer :target_planet_id, :index => true

      t.timestamps
    end
  end
end

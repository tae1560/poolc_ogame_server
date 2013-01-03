class CreatePlanets < ActiveRecord::Migration
  def change
    create_table :planets do |t|
      t.integer :galaxy
      t.integer :system
      t.integer :planet_number

      t.integer :user_id, :index => true

      t.timestamps
    end

    add_index :planets, [:galaxy, :system, :planet_number]

  end
end

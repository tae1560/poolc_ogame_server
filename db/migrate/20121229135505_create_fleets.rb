class CreateFleets < ActiveRecord::Migration
  def change
    create_table :fleets do |t|
      t.string :keyword
      t.string :reg_exp
      t.string :name

      t.timestamps
    end
  end
end

class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :keyword
      t.string :reg_exp
      t.string :name

      t.timestamps
    end
  end
end

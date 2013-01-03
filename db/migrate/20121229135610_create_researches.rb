class CreateResearches < ActiveRecord::Migration
  def change
    create_table :researches do |t|
      t.string :keyword
      t.string :reg_exp
      t.string :name

      t.timestamps
    end
  end
end

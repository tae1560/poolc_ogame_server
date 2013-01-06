class ChangeAttackTimeColumn < ActiveRecord::Migration
  def up
    change_column :attacks, :time, :datetime
  end

  def down
    change_column :attacks, :time, :integer
  end
end

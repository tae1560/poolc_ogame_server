class AddStatusInUsers < ActiveRecord::Migration
  def change
    add_column :users, :status, :string, :default => ""
  end
end

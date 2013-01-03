class AddMessageColumnToReport < ActiveRecord::Migration
  def change
    add_column :reports, :message, :text
  end
end

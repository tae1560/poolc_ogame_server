class AddMessageText < ActiveRecord::Migration
  def change
    add_column :reports, :report_text, :text
  end
end

class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :ogame_id, :unique => true, :index => true
      t.string :password
      t.datetime :last_login

      t.timestamps
    end
  end
end

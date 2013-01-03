class Attack < ActiveRecord::Base
  attr_accessible :metal, :crystal, :deuterium, :time

  belongs_to :start_planet, :class_name => Planet
  belongs_to :target_planet, :class_name => Planet
#start_planet_id
#target_planet_id

end

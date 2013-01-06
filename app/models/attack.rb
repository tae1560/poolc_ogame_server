class Attack < ActiveRecord::Base
  attr_accessible :metal, :crystal, :deuterium, :time

  belongs_to :start_planet, :class_name => Planet
  belongs_to :target_planet, :class_name => Planet

  validates :start_planet_id, :presence => true
  validates :target_planet_id, :presence => true
  validates :metal, :presence => true
  validates :crystal, :presence => true
  validates :deuterium, :presence => true
  validates :time, :presence => true

end

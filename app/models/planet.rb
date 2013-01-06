class Planet < ActiveRecord::Base
  attr_accessible :galaxy, :system, :planet_number

  belongs_to :user
  has_many :reports

  validates :user_id, :presence => true
  validates :galaxy, :presence => true, :numericality => true, :inclusion => { :in => 1..9 }
  validates :system, :presence => true, :numericality => true, :inclusion => { :in => 1..499 }
  validates :planet_number, :presence => true, :numericality => true, :inclusion => { :in => 1..15 }

  has_many :attacks, :foreign_key => :target_planet_id

  def coordinate
    self.galaxy.to_s + ":" + self.system.to_s + ":" + self.planet_number.to_s
  end

  def flight_duration planet, speed
    flight_duration = 10 + 3500 * Math.sqrt(10 * (2700 + 95 * (planet.system - self.system).abs) / speed)
  end
end

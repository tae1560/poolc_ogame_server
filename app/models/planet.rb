class Planet < ActiveRecord::Base
  attr_accessible :galaxy, :system, :planet_number

  belongs_to :user
  has_many :reports

  def coordinate
    self.galaxy.to_s + ":" + self.system.to_s + ":" + self.planet_number.to_s
  end
end

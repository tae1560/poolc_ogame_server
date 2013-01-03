class Report < ActiveRecord::Base
  attr_accessible :time, :message, :include_resources, :include_researches, :include_buildings, :include_fleets, :include_defenses

  belongs_to :planet

  has_many :report_buildings
  has_many :buildings, :through => :report_buildings

  has_many :report_defenses
  has_many :defenses, :through => :report_defenses

  has_many :report_fleets
  has_many :fleets, :through => :report_fleets

  has_many :report_researches
  has_many :researches, :through => :report_researches

  has_many :report_resources
  has_many :resources, :through => :report_resources

  #report.report_resources.where(:resource_id => Resource.where(:keyword => "Metal").first.id).last.value
  def get_fleet_value keyword
    fleet = Fleet.where(:keyword => keyword).first
    if fleet
      report_fleet = self.report_fleets.where(:fleet_id => fleet.id).last
      if report_fleet
        return report_fleet.value
      else
        return 0
      end
    end
  end

  def get_building_value keyword
    building = Building.where(:keyword => keyword).first
    if building
      report_building = self.report_buildings.where(:building_id => building.id).last
      if report_building
        return report_building.value
      else
        return 0
      end
    end
  end

  def get_defense_value keyword
    defense = Defense.where(:keyword => keyword).first
    if defense
      report_defense = self.report_defenses.where(:defense_id => defense.id).last
      if report_defense
        return report_defense.value
      else
        return 0
      end
    end
  end

  def get_research_value keyword
    research = Research.where(:keyword => keyword).first
    if research
      report_research = self.report_researches.where(:research_id => research.id).last
      if report_research
        return report_research.value
      else
        return 0
      end
    end
  end

  def get_resource_value keyword
    resource = Resource.where(:keyword => keyword).first
    if resource
      report_resource = self.report_resources.where(:resource_id => resource.id).last
      if report_resource
        return report_resource.value
      else
        return 0
      end
    end
  end

  def update_resource_value keyword, value
    resource = Resource.where(:keyword => keyword).first
    if resource
      report_resource = self.report_resources.where(:resource_id => resource.id).last
      if report_resource
        report_resource.value = value
        report_resource.save
      end
    end
  end
end

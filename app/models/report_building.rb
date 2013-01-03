class ReportBuilding < ActiveRecord::Base
  attr_accessible :value

  belongs_to :report
  belongs_to :building
end

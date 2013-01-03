class ReportFleet < ActiveRecord::Base
  attr_accessible :value

  belongs_to :report
  belongs_to :fleet
end

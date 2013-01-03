class ReportResearch < ActiveRecord::Base
  attr_accessible :value

  belongs_to :report
  belongs_to :research
end

class ReportDefense < ActiveRecord::Base
  attr_accessible :value

  belongs_to :report
  belongs_to :defense
end

class ReportResource < ActiveRecord::Base
  attr_accessible :value

  belongs_to :report
  belongs_to :resource
end

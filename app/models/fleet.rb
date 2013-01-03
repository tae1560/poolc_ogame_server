class Fleet < ActiveRecord::Base
  attr_accessible :keyword, :reg_exp, :name

  has_many :report_fleets
  has_many :reports, :through => :report_fleets
end

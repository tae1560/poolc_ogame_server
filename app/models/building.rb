class Building < ActiveRecord::Base
  attr_accessible :keyword, :reg_exp, :name

  has_many :report_building
  has_many :reports, :through => :report_building
end

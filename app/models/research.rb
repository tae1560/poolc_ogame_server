class Research < ActiveRecord::Base
  attr_accessible :keyword, :reg_exp, :name

  has_many :report_researches
  has_many :reports, :through => :report_researches
end

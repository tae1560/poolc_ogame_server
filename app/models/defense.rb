class Defense < ActiveRecord::Base
  attr_accessible :keyword, :reg_exp, :name

  has_many :report_defenses
  has_many :reports, :through => :report_defenses
end

class Resource < ActiveRecord::Base
  attr_accessible :keyword, :reg_exp, :name

  has_many :report_resources
  has_many :reports, :through => :report_resources
end

#coding : UTF-8
class User < ActiveRecord::Base
  attr_accessible :ogame_id, :password, :password_confirmation, :last_login, :status

  validates_confirmation_of :password
  validates :ogame_id, :presence => true, :uniqueness => true

  has_many :planets
  accepts_nested_attributes_for :planets

  def all_status
    {"i" => "부재", "hp" => "명예", "v" => "휴가", "n" => "초보자", "A" => "관리자",  "b" => "정지"}
  end

  def is_status status
    if self.status
      return self.status.include? status
    else
      return false
    end
  end

  def encrypt_password
    if self.password.present?
      self.password = Digest::SHA1.hexdigest(self.password)
    end
    if self.password_confirmation.present?
      self.password_confirmation = Digest::SHA1.hexdigest(self.password_confirmation)
    end
  end

  def self.authenticate(ogame_id="", password="")
    user = User.find_by_ogame_id(ogame_id)

    if user && user.match_password(password)
      user.last_login = Time.now
      user.save
      return user
    else
      return false
    end
  end

  def match_password(password="")
    self.password == Digest::SHA1.hexdigest(password)
  end

  def send_message message
    #self.gcm_devices.each do |gcm_device|
    #  notification = Gcm::Notification.new
    #  notification.device = gcm_device
    #  notification.collapse_key = "updates_available"
    #  notification.delay_while_idle = false
    #  notification.data = {:registration_ids => ["#{gcm_device.registration_id}"], :data => {:message_text => message}}
    #  notification.save!
    #end
    #Gcm::Notification.send_notifications
  end
end

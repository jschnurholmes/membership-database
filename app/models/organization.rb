module Organization
  def self.time_zone
    Time.find_zone!(Rails.configuration.x.organization_time_zone)
  end

  def self.today
    time_zone.today
  end
end

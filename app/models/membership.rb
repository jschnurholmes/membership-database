class Membership < ApplicationRecord
  # Behaviors
  include Discard::Model

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[id membership_type_id membership_period_id mailing_preference_id renewal_date created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[membership_type mailing_preference addresses members membership_records membership_periods]
  end

  # Relationships
  belongs_to :membership_type
  belongs_to :mailing_preference
  has_many   :addresses
  has_and_belongs_to_many :members, class_name: 'Person'
  has_many   :membership_records
  has_many   :membership_periods, through: :membership_records do
    def latest
      # If the membership hasn't been saved to the database yet, fall back on sorting the in-memory objects
      self.order(expiration_date: :desc).first ||
      self.sort{|a, b| b.membership_period.expiration_date <=> a.membership_period.expiration_date }.first
    end
  end

  accepts_nested_attributes_for :addresses, allow_destroy: true

  # Automatically set a unique token
  include Tokenable

  def member_names
    members.map{ |member| member.display_name }.join(' & ')
  end

  def current?(effective_date = Time.now)
    return period_contains_date?(effective_date)
  end

  def period_contains_date?(date)
    if(membership_periods.latest.effective_date <= date && membership_periods.latest.expiration_date >= date)
      true
    else
      false
    end
  end

  def renew
    current_period = MembershipPeriod.latest
    # require 'pry'; binding.pry
    if membership_periods.include?( current_period )
      errors.add(:membership_periods, 'already contains current period')

      false
    else
      membership_periods << current_period
      self.renewal_date = Time.now
      self.save
    end
  end

  def self.to_csv
    csv = "names, line_1, line_2, city, state, zip\n"
    Membership.all.each do |m|
      address = m.addresses.first
      if address.nil?
        csv << "#{m.member_names}\n"
      else
        csv << %|"#{m.member_names}","#{address.line_1}","#{address.line_2}","#{address.city}","#{address.state.abbreviation}","#{address.zip_code}"\n|
      end
    end
    csv
  end
end

class Membership < ApplicationRecord
  # Behaviors
  include SoftDeletable

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[id membership_type_id membership_period_id mailing_preference_id renewal_date created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[membership_type mailing_preference addresses members membership_records membership_periods]
  end

  def self.ransackable_scopes(auth_object = nil)
    %w{with_tags without_tags with_membership_types with_mailing_preferences with_members active_on in_membership_periods}
  end

  # Scope values are ids, dates, and tag names, so Ransack must not cast "1"/"0" to booleans.
  def self.ransackable_scopes_skip_sanitize_args
    ransackable_scopes
  end

  # The person-rooted scopes include a membership when any one of its members
  # qualifies, which is why without_tags reads as where(id:) and not where.not.
  scope :with_tags, ->(*tag_names) {
    where(id: Person.with_tags(tag_names).joins(:memberships).select('memberships_people.membership_id'))
  }

  scope :without_tags, ->(*tag_names) {
    where(id: Person.without_tags(tag_names).joins(:memberships).select('memberships_people.membership_id'))
  }

  scope :with_members, ->(*ids) {
    where(id: Person.with_members(ids).joins(:memberships).select('memberships_people.membership_id'))
  }

  scope :in_membership_periods, ->(*period_ids) {
    where(id: Person.in_membership_periods(period_ids).joins(:memberships).select('memberships_people.membership_id'))
  }

  scope :with_membership_types, ->(*ids) { where(membership_type_id: ids.flatten) }

  scope :with_mailing_preferences, ->(*ids) { where(mailing_preference_id: ids.flatten) }

  scope :active_on, ->(date) {
    where(id: joins(:membership_periods).
                where('membership_periods.effective_date <= :date AND membership_periods.expiration_date >= :date', date: date.to_date).
                select(:id))
  }

  # Relationships
  # Optional, as before Rails 5, so renewing a membership on a soft-deleted type still saves.
  belongs_to :membership_type, optional: true
  belongs_to :mailing_preference, optional: true
  has_many   :addresses
  has_and_belongs_to_many :members, class_name: 'Person'
  has_many   :membership_records
  has_many   :membership_periods, through: :membership_records do
    def latest
      # Preloaded periods are picked in memory, sparing a query per membership on list pages.
      return max_by(&:expiration_date) if loaded?

      # If the membership hasn't been saved to the database yet, fall back on sorting the in-memory objects
      self.order(expiration_date: :desc).first ||
      self.sort{|a, b| b.membership_period.expiration_date <=> a.membership_period.expiration_date }.first
    end
  end

  accepts_nested_attributes_for :addresses, allow_destroy: true

  # Automatically set a unique token
  include Tokenable

  delegate :effective_date, :expiration_date, to: :latest_membership_period, allow_nil: true

  def latest_membership_period
    membership_periods.latest
  end

  def member_names(people = members)
    people.map{ |member| member.display_name }.join(' & ')
  end

  def current?(effective_date = Organization.today)
    Membership.active_on(effective_date).exists?(id)
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

class Person < ApplicationRecord
  # Behaviors
  include SoftDeletable

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[id first_name middle_name last_name preferred_name token created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[phone_numbers email_addresses memberships]
  end

  def self.ransackable_scopes(auth_object = nil)
    %w{with_tags without_tags with_membership_types with_mailing_preferences with_members active_on in_membership_periods}
  end

  # Scope values are ids, dates, and tag names, so Ransack must not cast "1"/"0" to booleans.
  def self.ransackable_scopes_skip_sanitize_args
    ransackable_scopes
  end

  scope :with_tags, ->(*tag_names) {
    where(id: joins(:tags).where(tags: { name: tag_names.flatten }).select(:id))
  }

  scope :without_tags, ->(*tag_names) {
    where.not(id: joins(:tags).where(tags: { name: tag_names.flatten }).select(:id))
  }

  scope :with_membership_types, ->(*ids) {
    where(id: joins(:memberships).where(memberships: { membership_type_id: ids.flatten }).select(:id))
  }

  scope :with_mailing_preferences, ->(*ids) {
    where(id: joins(:memberships).where(memberships: { mailing_preference_id: ids.flatten }).select(:id))
  }

  scope :with_members, ->(*ids) { where(id: ids.flatten) }

  scope :active_on, ->(date) {
    where(id: Membership.active_on(date).joins(:members).select('memberships_people.person_id'))
  }

  # Current members and each period's recorded members, so a gap in either source drops no one.
  scope :in_membership_periods, ->(*period_ids) {
    period_ids = period_ids.flatten
    current = joins(memberships: :membership_records).
                where(membership_records: { membership_period_id: period_ids }).
                select(:id)
    recorded = MembershipRecord.
                 from("membership_records, JSON_TABLE(membership_records.members, '$[*]' COLUMNS (person_id INT PATH '$')) AS recorded").
                 where(membership_period_id: period_ids).
                 select('recorded.person_id')
    where(id: current).or(where(id: recorded))
  }

  # Each active person counts once, under their active membership whose latest period expires last.
  def self.count_by_membership_type(date = Organization.today)
    latest_expirations = MembershipRecord.joins(:membership_period).
                           group(:membership_id).
                           select('membership_records.membership_id, MAX(membership_periods.expiration_date) AS expiration_date')

    ranked = Membership.active_on(date).
               joins(:members).
               joins("INNER JOIN (#{latest_expirations.to_sql}) AS latest ON latest.membership_id = memberships.id").
               select(<<~SQL.squish)
                 memberships_people.person_id, memberships.membership_type_id,
                 ROW_NUMBER() OVER (PARTITION BY memberships_people.person_id
                                    ORDER BY latest.expiration_date DESC, memberships.id DESC) AS position
               SQL

    Membership.unscoped.from(ranked, :ranked).where('ranked.position = 1').group('ranked.membership_type_id').count
  end

  # Relationships
  has_many :phone_numbers
  has_many :email_addresses
  has_and_belongs_to_many :memberships do
    def latest
      # Sort memberships by descending chronological order, the first is the latest
      self.sort{|a, b| b.membership_periods.latest.expiration_date <=> a.membership_periods.latest.expiration_date }.first
    end
  end
  has_and_belongs_to_many :tags

  def tags_attributes=(attrs)
    self.tag_ids = attrs.values
      .reject { |a| a['_destroy'] == '1' }
      .map { |a| a['id'] }
      .reject(&:blank?)
  end

  accepts_nested_attributes_for :phone_numbers,
                                allow_destroy: true,
                                reject_if: proc { |attrs| attrs['_destroy'] != '1' && attrs['phone_number'].blank? }

  accepts_nested_attributes_for :email_addresses,
                                allow_destroy: true,
                                reject_if: proc { |attrs| attrs['_destroy'] != '1' && attrs['email'].blank? }

  # Automatically set a unique token
  include Tokenable

  def card_data
    {card_number: latest_card_number, token: token}.to_json
  end

  def names
    to_ret = []
    [first_name, middle_name, last_name].each do |name|
      to_ret << name if name.present?
    end
    to_ret
  end

  def sortable_name
    "#{last_name}, #{first_name} #{middle_name}"
  end

  def display_name
    preferred_name.present? ? preferred_name : names.join(' ')
  end

  def active?(effective_date = Organization.today)
    memberships.active_on(effective_date).exists?
  end

  def expiration_date
    if memberships.size > 0
      memberships.collect{|m| m.membership_periods.latest.expiration_date }.
          sort.last
    else
      'N/A'
    end
  end

  def has_membership_for_period?(membership_period)
    if memberships.select{|m| m.membership_period == membership_period }
      true
    else
      false
    end
  end

end

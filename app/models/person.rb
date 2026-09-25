class Person < ApplicationRecord
  # Behaviors
  include Discard::Model

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[id first_name middle_name last_name preferred_name token created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[phone_numbers email_addresses memberships]
  end

  def self.ransackable_scopes(auth_object = nil)
    %w{without_tags}
  end

  scope :without_tags, ->(*tag_names) {
    where.not(id: joins(:tags).where(tags: { name: tag_names.flatten }).select(:id))
  }

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

  def active?(effective_date = Time.now)
    m = memberships.latest
    m && m.current?(effective_date)
  end

  def expiration_date
    if memberships.count > 0
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

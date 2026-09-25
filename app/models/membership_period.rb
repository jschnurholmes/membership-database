class MembershipPeriod < ApplicationRecord
  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[id effective_date expiration_date created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[membership_records memberships]
  end

  # Relationships
  has_many :membership_records
  has_many :memberships, through: :membership_records

  FORMAT_STRING =  I18n.t('date_format')

  def to_s
    "#{effective_date.strftime(FORMAT_STRING)} - #{expiration_date.strftime(FORMAT_STRING)}"
  end

  def self.latest
    MembershipPeriod.order(expiration_date: :desc).first
  end
end

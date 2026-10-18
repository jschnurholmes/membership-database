class MembershipType < ApplicationRecord
  # Behaviors
  include SoftDeletable

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[id name created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[memberships]
  end

  # Relationships
  has_many :memberships

  def to_s
    name
  end
end

class MembershipRecord < ApplicationRecord
  belongs_to  :membership
  belongs_to  :membership_period

  serialize   :members

  before_save :update_serialized_members

  # before_save callback
  # Updates the serialized members field so we keep a permanent record of each
  # membership's members in each year, allowing for members to add new or
  # existing members to their membership (e.g., because of marriages) without
  # losing our record of who each membership belonged to in a given year.
  def update_serialized_members
    member_list = self.membership.members.select(:id)
    unless member_list.empty?
      self.members = member_list.map{|p| p.id}
    end
  end
end

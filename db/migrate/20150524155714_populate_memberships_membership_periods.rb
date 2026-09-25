class PopulateMembershipsMembershipPeriods < ActiveRecord::Migration[4.2]
  def change
    Membership.all.each do |membership|
      ActiveRecord::Base.connection.execute(
          %Q{INSERT INTO memberships_membership_periods (membership_id, membership_period_id) VALUES ('#{membership.id}', '#{membership.membership_period_id}')})
    end
  end
end

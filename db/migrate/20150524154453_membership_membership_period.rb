class MembershipMembershipPeriod < ActiveRecord::Migration[4.2]
  def change
    create_table :memberships_membership_periods, id: false do |t|
      t.references :membership
      t.references :membership_period
    end
    add_index :memberships_membership_periods, [ :membership_id, :membership_period_id ], name: 'm_mp_mid_mpid'
    add_index :memberships_membership_periods, :membership_id
  end
end

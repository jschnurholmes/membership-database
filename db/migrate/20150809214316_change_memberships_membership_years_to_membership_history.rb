class ChangeMembershipsMembershipYearsToMembershipHistory < ActiveRecord::Migration[4.2]
  def change
    rename_table :membership_periods_memberships, :membership_records

    add_column :membership_records, :members, :text
  end
end

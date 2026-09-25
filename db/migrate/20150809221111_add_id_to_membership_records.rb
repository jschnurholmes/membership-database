class AddIdToMembershipRecords < ActiveRecord::Migration[4.2]
  def change
    add_column :membership_records, :id, :primary_key
  end
end

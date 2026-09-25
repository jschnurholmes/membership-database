class CreateMembershipPeriods < ActiveRecord::Migration[4.2]
  def change
    create_table :membership_periods do |t|
      t.date :effective_date
      t.date :expiration_date

      t.timestamps
    end
  end
end

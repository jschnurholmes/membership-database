class RemoveEffectiveAndExpirationDateFromMembership < ActiveRecord::Migration[4.2]
  def change
    change_table :memberships do |t|
      t.remove :effective_date, :expiration_date
      t.belongs_to :membership_period
    end
  end
end

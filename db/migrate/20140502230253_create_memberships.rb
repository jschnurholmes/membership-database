class CreateMemberships < ActiveRecord::Migration[4.2]
  def change
    create_table :memberships do |t|
      t.belongs_to :membership_type
      t.date :effective_date
      t.date :expiration_date
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :memberships, :deleted_at
  end
end

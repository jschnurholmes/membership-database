class CreateMembershipTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :membership_types do |t|
      t.string :name
      t.decimal :cost, :precision => 15, :scale => 2
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :membership_types, :deleted_at
  end
end

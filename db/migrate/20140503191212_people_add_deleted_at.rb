class PeopleAddDeletedAt < ActiveRecord::Migration[4.2]
  def change
    change_table :people do |t|
      t.datetime :deleted_at
      t.index :deleted_at
    end
  end
end

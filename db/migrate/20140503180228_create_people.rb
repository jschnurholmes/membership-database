class CreatePeople < ActiveRecord::Migration[4.2]
  def change
    create_table :people do |t|
      t.string :first_name
      t.string :middle_name
      t.string :last_name

      t.timestamps
    end

    create_join_table :memberships, :people do |t|
      t.index :membership_id
      t.index :person_id
    end
  end
end

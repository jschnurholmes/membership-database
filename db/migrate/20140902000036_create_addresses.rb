class CreateAddresses < ActiveRecord::Migration[4.2]
  def change
    create_table :addresses do |t|
      t.string :line_1
      t.string :line_2
      t.string :city
      t.integer :state_id
      t.string :zip_code

      t.timestamps
    end
  end
end

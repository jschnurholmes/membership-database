class CreatePhoneNumbers < ActiveRecord::Migration[4.2]
  def change
    create_table :phone_numbers do |t|
      t.belongs_to :person
      t.belongs_to :phone_type

      t.string :phone_number
      t.boolean :primary?

      t.timestamps
    end
  end
end

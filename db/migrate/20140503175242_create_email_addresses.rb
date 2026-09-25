class CreateEmailAddresses < ActiveRecord::Migration[4.2]
  def change
    create_table :email_addresses do |t|
      t.belongs_to :person
      t.belongs_to :email_type

      t.string :email
      t.boolean :primary?

      t.timestamps
    end
  end
end

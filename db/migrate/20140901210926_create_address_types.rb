class CreateAddressTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :address_types do |t|
      t.string :name
      t.boolean :primary?

      t.timestamps
    end
  end
end

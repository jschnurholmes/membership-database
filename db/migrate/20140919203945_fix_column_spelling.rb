class FixColumnSpelling < ActiveRecord::Migration[4.2]
  def change
    rename_column :people, :latest_cart_number, :latest_card_number
  end
end

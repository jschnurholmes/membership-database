class PhoneNumbersChangePhoneTypeToType < ActiveRecord::Migration[4.2]
  def change
    rename_column :phone_numbers, :phone_type_id, :type_id
  end
end

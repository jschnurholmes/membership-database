class EmailAddressesChangeEmailTypeToType < ActiveRecord::Migration[4.2]
  def change
    rename_column :email_addresses, :email_type_id, :type_id
  end
end

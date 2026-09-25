class AddTypeToAddress < ActiveRecord::Migration[4.2]
  def change
    add_belongs_to :addresses, :address_type
  end
end

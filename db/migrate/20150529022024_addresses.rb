class Addresses < ActiveRecord::Migration[4.2]
  def change
    add_column :addresses, :deleted_at, :timestamp
  end
end

class AddRelationalFieldToAddress < ActiveRecord::Migration[4.2]
  def change
    add_belongs_to :addresses, :membership
    add_column :addresses, :deleted_at, :integer
    add_index :addresses, :deleted_at
  end
end

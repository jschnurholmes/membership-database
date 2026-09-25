class AddRelationalStateRelationToAddress < ActiveRecord::Migration[4.2]
  def change
    remove_column :addresses, :state_id
    add_belongs_to :addresses, :state
  end
end

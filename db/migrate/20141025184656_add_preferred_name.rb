class AddPreferredName < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :preferred_name, :string
  end
end

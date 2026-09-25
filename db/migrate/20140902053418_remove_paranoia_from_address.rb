class RemoveParanoiaFromAddress < ActiveRecord::Migration[4.2]
  def change
    remove_column :addresses, :deleted_at
  end
end

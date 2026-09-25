class AddPriorityToTags < ActiveRecord::Migration[7.2]
  def change
    add_column :tags, :priority, :integer
  end
end

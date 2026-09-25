class AddColorToTags < ActiveRecord::Migration[7.2]
  def change
    add_column :tags, :color, :text
  end
end

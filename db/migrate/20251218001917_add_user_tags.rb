class AddUserTags < ActiveRecord::Migration[7.2]
  def change
  	create_table :tags do |t|
  		t.string :name
  		t.timestamps
  	end
  	create_table :people_tags, id: false do |t|
  		t.references :person
  		t.references :tag
  		t.timestamps
	end
	add_index :people_tags, [:person_id, :tag_id]
  end
end

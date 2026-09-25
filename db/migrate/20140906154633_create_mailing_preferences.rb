class CreateMailingPreferences < ActiveRecord::Migration[4.2]
  def change
    create_table :mailing_preferences do |t|
      t.string :name

      t.timestamps
    end
  end
end

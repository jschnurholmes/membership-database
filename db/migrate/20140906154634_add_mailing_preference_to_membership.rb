class AddMailingPreferenceToMembership < ActiveRecord::Migration[4.2]
  def change
    add_belongs_to :memberships, :mailing_preference
  end
end

class AddTokenToMembershipAndPerson < ActiveRecord::Migration[4.2]

  # Add methods to Membership and Person to allow calling protected generate_token method
  class Membership
    def set_token
      generate_token
    end
  end

  class Person
    def set_token
      generate_token
    end
  end

  def change
    add_column :memberships, :token, :string
    add_index :memberships, :token


    Membership.transaction do
      Membership.all.each do |membership|
        membership.set_token
        membership.save
      end
    end

    add_column :people, :token, :string
    add_index :people, :token
    add_column :people, :latest_cart_number, :integer, null: false, default: 0

    Person.transaction do
      Person.all.each do |person|
        person.set_token
        person.save
      end
    end
  end
end

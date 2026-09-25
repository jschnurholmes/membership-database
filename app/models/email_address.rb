class EmailAddress < ApplicationRecord
  # Relationships
  belongs_to :person
  belongs_to :type, class_name: 'EmailType'

  def to_s
    email
  end
end

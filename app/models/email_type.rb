class EmailType < ApplicationRecord
  # Relationships
  has_many :email_addresses

  def to_s
    self.name
  end
end

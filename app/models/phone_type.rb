class PhoneType < ApplicationRecord
  # Relationships
  has_many :numbers, class_name: 'PhoneNumber'

  def to_s
    self.name
  end
end

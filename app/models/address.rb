class Address < ApplicationRecord
  include SoftDeletable
  # Relationships
  belongs_to :state
  belongs_to :membership
  belongs_to :address_type

  def to_s
    full_address = self.line_1 + "\n"
    if self.line_2.present?
        full_address += self.line_2 + "\n"
    end
    full_address + "#{self.city}, #{self.state} #{self.zip_code}"
  end
end

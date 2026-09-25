class AddressType < ApplicationRecord
  has_many :addresses

  def to_s
    self.name
  end
end

class PhoneNumber < ApplicationRecord
  # Behaviors
  include ActionView::Helpers::NumberHelper

  # Relationships
  belongs_to :person
  belongs_to :type, class_name: 'PhoneType'

  def to_s
    number_to_phone phone_number, area_code: true
  end
end

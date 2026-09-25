class MailingPreference < ApplicationRecord
  has_many :memberships

  def to_s
    name
  end
end

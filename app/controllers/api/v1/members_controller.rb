class Api::V1::MembersController < ApplicationController
  def index
    members = []
    Person.all.each do |m|
      membership = m.memberships.latest;
      members << {
          member_id:       m.id,
          membership_id:   membership.present? ? membership.id : nil,
          last_name:       m.last_name,
          middle_name:     m.middle_name,
          first_name:      m.first_name,
          preferred_name:  m.preferred_name,
          expiration_date: m.expiration_date
      }
    end

    respond_to do |format|
      format.json do
        send_data members.to_json and return
      end
    end
  end
end
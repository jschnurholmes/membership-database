module ReportsHelper

  def address_list_csv( options = {} )
    memberships = Membership.joins( :addresses ).
                             # where( mailing_preference_id: [2,3] ).
                             group( 'memberships.id' )
    CSV.generate(**options) do |csv|
      csv << [ 'Mail Label', 'Address', 'City', 'St', 'Zip', 'Mailing Preference', 'Expiration Date' ]
      memberships.each do |m|
        m.addresses.each do |a|
          csv << [ m.member_names,
                   a.line_2.present? ? a.line_1 + ', ' + a.line_2 : a.line_1,
                   a.city,
                   a.state.abbreviation,
                   a.zip_code,
                   m.mailing_preference,
                   m.membership_periods.latest.expiration_date,
          ]
        end
      end
    end
  end

  def email_list_string( options = {} )
    people = Person.joins( :memberships, :email_addresses ).
        group( 'people.id' )
    list = []
    people.each do |person|
      list << "#{person.display_name} <#{person.email_addresses.first}>"
    end
    list.join(', ')
  end

  def member_directory_csv( options = {} )
    memberships = Membership.includes( :membership_records, :members,
                                       :membership_type ).all
    CSV.generate(**options) do |csv|
      csv << [ 'Membership ID', 'Member ID', 'Membership Type', 'Mailing Preferences',
               'Expiration Date', 'Last Name', 'First Name', 'Preferred Name',
               'Phone 1 Type', 'Phone 1', 'Phone 2 Type', 'Phone 2',
               'Phone 3 Type', 'Phone 3', 'Email 1 Type', 'Email 1',
               'Email 2 Type', 'Email 2', 'Address 1 Type', 'Address 1',
               'Address 2 Type', 'Address 2']
      memberships.each do |m|
        m.members.each do |p|
          member_data =[
              m.id,
              p.id,
              m.membership_type,
              m.mailing_preference,
              m.membership_periods.latest.expiration_date,
              p.last_name,
              p.first_name,
              p.display_name,
          ]

          # Add the phone numbers
          (0..2).each do |i|
            phone_number = p.phone_numbers[i]
            if phone_number
              member_data += [ phone_number, phone_number.type ]
            else
              member_data += [ '', '' ]
            end
          end

          # Add the email addresses
          (0..1).each do |i|
            email_address = p.email_addresses[i]
            if email_address
              member_data += [ email_address, email_address.type ]
            else
              member_data += [ '', '' ]
            end
          end

          # Add the mailing addresses
          (0..1).each do |i|
            address = m.addresses[i]
            if address
              member_data += [ address, address.address_type ]
            else
              member_data += [ '', '' ]
            end
          end

          csv << member_data
        end
      end
    end
  end

  def member_list_csv( members, options = {} )
    CSV.generate(**options) do |csv|
      csv << [ 'Membership ID', 'Member ID', 'Name', 'Membership Type',
               'Expiration Date' ]
      members.each do |p|
        m = p.memberships.latest
        csv << [
            m&.id,
            p.id,
            p.display_name,
            m&.membership_type&.name,
            p.expiration_date
        ]
      end
    end
  end
end

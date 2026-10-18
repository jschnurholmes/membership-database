module ReportsHelper
  REPORT_FORMAT_LABELS = { html: 'View', text: 'View', csv: 'Download CSV' }.freeze

  def report_format_label( format )
    REPORT_FORMAT_LABELS.fetch( format )
  end

  def path_for_report_format( report, format )
    send( report.path_helper, format: ( :csv if format == :csv ) )
  end

  def member_filter_people( values )
    Reports::Selection.new( Person, values.except( :with_members ) ).result.order( :last_name, :first_name )
  end

  def report_menu_link( report, css_class )
    link_to report.label, '#', class: css_class,
            data: { bs_toggle: 'modal', bs_target: '#report-filter-modal',
                    filters_url: report_filters_path( report: report.key ) }
  end

  # Ransack builds sort URLs from every request param, which after a POST includes the CSRF token.
  def report_sort_link( search, attribute, label )
    sort_link( search, attribute, label, authenticity_token: nil )
  end

  def address_list_csv( selection, options = {} )
    memberships = selection.result.joins( :addresses ).
                                   group( 'memberships.id' )
    CSV.generate(**options) do |csv|
      csv << [ 'Mail Label', 'Address', 'City', 'St', 'Zip', 'Mailing Preference', 'Expiration Date' ]
      memberships.each do |m|
        members = selection.members_of( m )
        next if members.empty?

        m.addresses.each do |a|
          csv << [ m.member_names( members ),
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

  def email_list_string( selection, options = {} )
    people = selection.result.joins( :memberships, :email_addresses ).
        group( 'people.id' )
    list = []
    people.each do |person|
      list << "#{person.display_name} <#{person.email_addresses.first}>"
    end
    list.join(', ')
  end

  def member_directory_csv( selection, options = {} )
    memberships = selection.result.includes( :membership_records, :membership_type,
                                             members: :tags )
    # Only tags held by someone appearing in the report get a column.
    tags = memberships.flat_map { |m| selection.members_of( m ) }.flat_map( &:tags ).uniq.
                       sort_by { |t| [ t.priority || 0, t.name.to_s ] }
    CSV.generate(**options) do |csv|
      csv << [ 'Membership ID', 'Member ID', 'Membership Type', 'Mailing Preferences',
               'Expiration Date', 'Last Name', 'First Name', 'Preferred Name',
               'Phone 1 Type', 'Phone 1', 'Phone 2 Type', 'Phone 2',
               'Phone 3 Type', 'Phone 3', 'Email 1 Type', 'Email 1',
               'Email 2 Type', 'Email 2', 'Address 1 Type', 'Address 1',
               'Address 2 Type', 'Address 2'] + tags.map { |t| t.name.titleize }
      memberships.each do |m|
        selection.members_of( m ).each do |p|
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

          # Add the tags
          person_tag_ids = p.tags.map( &:id )
          member_data += tags.map { |t| person_tag_ids.include?( t.id ) ? 'Y' : '' }

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

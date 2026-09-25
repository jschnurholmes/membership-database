module MembershipsHelper
  def member_name_links(members)
    members.map{ |member| link_to(member.display_name, person_path(member)) }.join(' & ')
  end
end

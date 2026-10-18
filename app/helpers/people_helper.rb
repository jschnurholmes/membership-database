module PeopleHelper
  def get_qr_code(person)
    image_tag qr_code_person_path(person), alt: ''
  end
end

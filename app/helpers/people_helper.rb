module PeopleHelper
  def get_qr_code(person)
    qr_code_url = "https://api.qrserver.com/v1/create-qr-code/?size=600x600&margin=0&format=png&data="
    image_tag qr_code_url + CGI::escape(person.card_data) {}
  end
end

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

config = YAML::load_file(File.join(Rails.root, 'db', 'seeds.yml'))
[State, MailingPreference, PhoneType, EmailType, AddressType, MembershipType, Tag].each do |klass|
  klass.create(config[klass.table_name])
end

#Membership Periods
START_MONTH = 5
START_DATE = 1
END_MONTH = 8
END_DATE = 31
CURRENT_DATE = DateTime.now
CURRENT_YEAR = CURRENT_DATE.month < 8 ? CURRENT_DATE.year - 1 : CURRENT_DATE.year
MembershipPeriod.create(
  effective_date: DateTime.new(CURRENT_YEAR, START_MONTH, START_DATE),
  expiration_date: DateTime.new(CURRENT_YEAR + 1, END_MONTH, END_DATE)
)
MembershipPeriod.create(
  effective_date: DateTime.new(CURRENT_YEAR + 1, START_MONTH, START_DATE),
  expiration_date: DateTime.new(CURRENT_YEAR + 2, END_MONTH, END_DATE)
)


# Default User
User.create(email: (ENV['USER'] || 'developer') + '@example.com', password: 'changeme')

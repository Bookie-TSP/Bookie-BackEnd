# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Member.create(email: 'bookie@ku.th', password: '12341234', first_name: 'test', last_name: 'test', phone_number: 'test', identification_number: 'test')
Address.create(first_name: 'test1', last_name: 'test1', latitude: 'testest', longitude: 'testest', information: 'tetestes', member_id: 1)
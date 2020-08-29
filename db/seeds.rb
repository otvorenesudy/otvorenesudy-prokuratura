# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Office.create!(
  destroyed_at: Time.zone.now,
  # TODO: official date was when?
  name: 'Okresná prokuratúra Šaľa',
  address: 'N/A',
  zipcode: '927 01',
  city: 'Šaľa',
  phone: 'N/A',
  registry: { phone: 'N/A', hours: { monday: 'N/A', tuesday: 'N/A', wednesday: 'N/A', thursday: 'N/A', friday: 'N/A' } }
)

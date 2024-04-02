# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

office =
  Office.find_or_create_by!(
    name: 'Okresná prokuratúra Šaľa',
    address: 'N/A',
    zipcode: '927 01',
    city: 'Šaľa',
    phone: 'N/A',
    registry: {
      phone: 'N/A',
      hours: {
        monday: 'N/A',
        tuesday: 'N/A',
        wednesday: 'N/A',
        thursday: 'N/A',
        friday: 'N/A'
      }
    }
  )

# TODO: official date was when?
office.update!(destroyed_at: Time.zone.now)

special_prosecutors_office = Office.find_or_initialize_by(name: 'Úrad špeciálnej prokuratúry')

special_prosecutors_office.update!(
  type: :specialized,
  address: 'Štúrova 2',
  zipcode: '812 85',
  city: 'Bratislava 1',
  phone: '033/2837 196, 033/2837 192',
  fax: '033/2837 175, 033/2837 189',
  email: 'Podatelna.USPGP@genpro.gov.sk',
  electronic_registry: 'ico://sk/00166481',
  destroyed_at: Date.parse('2024-02-08'),
  registry: {
    phone: nil,
    hours: {
      monday: '8:00 – 15:00',
      tuesday: '8:00 – 15:00',
      wednesday: '8:00 – 15:00',
      thursday: '8:00 – 15:00',
      friday: '8:00 – 15:00'
    }
  }
)

Dir[Rails.root.join('data/genpro_gov_sk/criminality/paragraph-definitions-*')].each do |path|
  _, type = *path.match(/(old|new).csv/)

  CSV
    .open(path, headers: true)
    .each do |row|
      value = "#{row[2].strip} [#{type}]"
      name = "#{row[2].strip} – #{row[3].strip.capitalize}"

      paragraph = Paragraph.find_or_initialize_by(value: value, type: type)

      paragraph.update!(name: name)
    end
end

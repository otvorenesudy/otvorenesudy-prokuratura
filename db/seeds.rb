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
      phone: 'N/A', hours: { monday: 'N/A', tuesday: 'N/A', wednesday: 'N/A', thursday: 'N/A', friday: 'N/A' }
    }
  )

# TODO: official date was when?
office.update!(destroyed_at: Time.zone.now)

Dir[Rails.root.join('data/genpro_gov_sk/criminality/paragraph-definitions-*')].each do |path|
  _, type = *path.match(/(old|new).csv/)

  CSV.open(path, headers: true).each do |row|
    value = "#{row[2].strip} [#{type}]"
    name = "#{row[2].strip} – #{row[3].strip.capitalize}"

    paragraph = Paragraph.find_or_initialize_by(value: value, type: type)

    paragraph.update(name: name)
  end
end

require 'rails_helper'

RSpec.describe 'MinvSk::Criminality', type: :feature do
  it 'correctly imports and parses data', webmock: :disabled do
    MinvSk::Criminality.import

    validations = [
      { year: 1997, paragraph: '§ 231 [old]', metric: :persons_all, count: 169 },
      { year: 1998, paragraph: '§ 284 [old]', metric: :crime_discovered, count: 114 },
      { year: 2002, paragraph: '§ 269 [old]', metric: :crime_solved, count: 4 },
      { year: 2008, paragraph: '§ 205 [new]', metric: :persons_alcohol_abuse, count: 2 },
      { year: 2012, paragraph: '§ 305/2 [new]', metric: :crime_discovered, count: 43 },
      { year: 2016, paragraph: '§ 251 [new]', metric: :crime_solved, count: 17 },
      { year: 2018, paragraph: '§ 236 [new]', metric: :crime_drug_abuse, count: 1 },
      { year: 2020, paragraph: '§ 341 [new]', metric: :crime_solved, count: 2 },
      { year: 2022, paragraph: '§ 200 [new]', metric: :crime_drug_abuse, count: 1 },
      { year: 2023, paragraph: '§ 360A [new]', metric: :persons_all, count: 77 }
    ]

    validations.each { |attributes| expect(Crime.find_by(attributes)).to be_present }
  end
end

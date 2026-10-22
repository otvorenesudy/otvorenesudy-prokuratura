# frozen_string_literal: true

# == Schema Information
#
# Table name: prosecutors
#
#  id                                :bigint           not null, primary key
#  declarations                      :jsonb
#  decrees_count                     :bigint           default(0)
#  name                              :string           not null
#  name_parts                        :jsonb            not null
#  news                              :jsonb
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  genpro_gov_sk_prosecutors_list_id :bigint
#
# Indexes
#
#  index_prosecutors_on_genpro_gov_sk_prosecutors_list_id  (genpro_gov_sk_prosecutors_list_id)
#  index_prosecutors_on_name                               (name)
#  index_prosecutors_on_name_parts                         (name_parts)
#
# Foreign Keys
#
#  fk_rails_...  (genpro_gov_sk_prosecutors_list_id => genpro_gov_sk_prosecutors_lists.id)
#
require 'rails_helper'

RSpec.describe Prosecutor, type: :model do
  subject { build(:prosecutor) }

  it { is_expected.to belong_to(:genpro_gov_sk_prosecutors_list).optional(true) }
  it { is_expected.to validate_presence_of(:name) }

  describe '.remove_excluded_urls_from_news!' do
    it 'drops the articles from the excluded addresses' do
      excluded = File.readlines(Rails.root.join('data/newsable/excluded-urls.txt'), chomp: true).first
      prosecutor = create(:prosecutor, news: { data: [{ url: excluded }, { url: 'https://dennikn.sk/1/' }] })
      untouched = create(:prosecutor, news: nil)
      clean = create(:prosecutor, news: { data: [{ url: 'https://dennikn.sk/4100001/' }] })

      expect { described_class.remove_excluded_urls_from_news! }.not_to(change { clean.reload.updated_at })

      expect(prosecutor.reload.articles).to eq([{ 'url' => 'https://dennikn.sk/1/' }])
      expect(untouched.reload.articles).to eq([])
      expect(clean.articles).to eq([{ 'url' => 'https://dennikn.sk/4100001/' }])
    end
  end

  describe 'the declarations' do
    it 'are refused when they do not follow the shape of an imported declaration' do
      prosecutor = build(:prosecutor, declarations: [{ name: 'JUDr. Ján Novák', year: 2024 }])

      expect(prosecutor).not_to be_valid
      expect(prosecutor.errors).to be_of_kind(:declarations, :invalid)
    end
  end

  describe '.find_by_fuzzy_name' do
    it 'finds a prosecutor by the parts of the name, regardless of diacritics, those at the office first' do
      kosice = Office.find_by!(name: 'Krajská prokuratúra v Košiciach')
      novak = create(:prosecutor, name: 'JUDr. Ján Novák', name_parts: { first: 'Ján', last: 'Novák' })
      namesake = create(:prosecutor, name: 'JUDr. Ján Novák, PhD.', name_parts: { first: 'Ján', last: 'Novák' })
      create(:appointment, prosecutor: namesake, office: kosice)
      create(:appointment, prosecutor: novak, office: Office.find_by!(name: 'Okresná prokuratúra Žilina'))

      expect(described_class.find_by_fuzzy_name('Jan  Novak', office: kosice)).to eq(namesake)
      expect(described_class.find_by_fuzzy_name('Ján Novák')).to eq(namesake)
      expect(described_class.find_by_fuzzy_name('Peter Novák')).to be_nil
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenproGovSk::Prosecutors do
  describe '.import' do
    let(:list) { %r{/fileadmin/Menny_zoznam_prokuratorov_SR/2026/Menny_zoznam_prokuratorov_SR_k_2026_10_05\.pdf} }

    before do
      stub_source('https://www.genpro.gov.sk/menny-zoznam-prokuratorov-slovenskej-republiky',
                  'genpro_gov_sk/prosecutors/listing.html')
      stub_source(list, 'genpro_gov_sk/prosecutors/list-page-1.pdf')
    end

    it 'imports the prosecutors of the latest list, appointed to their offices' do
      described_class.import

      adamcova = Prosecutor.find_by!(name: 'JUDr. Ingrid Adamcová')

      expect(Prosecutor.count).to eq(27)
      expect(adamcova.name_parts).to include('first' => 'Ingrid', 'last' => 'Adamcová')
      expect(adamcova.offices.map(&:name)).to eq(['Generálna prokuratúra Slovenskej republiky'])
      expect(Appointment.current.temporary.count).to eq(1)
    end

    it 'imports a list once, unless forced, and ends the appointments of those it no longer names' do
      described_class.import
      retired = create(:prosecutor, name: 'JUDr. Bývalý Prokurátor')
      create(:appointment, prosecutor: retired, office: Office.first)

      described_class.import

      expect(retired.appointments.reload).to be_present

      described_class.import(force: true)

      expect(retired.appointments.reload).to be_empty
      expect(retired.past_appointments.count).to eq(1)
      digest = Digest::MD5.hexdigest(fixture('genpro_gov_sk/prosecutors/list-page-1.pdf').binread)
      expect(GenproGovSk::ProsecutorsList.where(digest:).count).to eq(1)
    end

    # The import runs in a thread of its own beside a transaction on another connection, so neither runs in the
    # example's transaction: what they commit stays, and the example deletes it.
    context 'with another transaction open' do
      self.use_transactional_tests = false

      let(:other) { ActiveRecord::Base.connection_pool.checkout }
      let(:imports) { [] }

      after do
        other.disconnect!
        ActiveRecord::Base.connection_pool.remove(other)
        imports.each(&:join)

        [Appointment, Prosecutor, GenproGovSk::ProsecutorsList].each(&:delete_all)
        refresh_search_views
      end

      def start_import
        Thread.new { ActiveRecord::Base.connection_pool.with_connection { described_class.import } }
              .tap { |import| imports << import }
      end

      # Until the import finished, or waits for a lock the other transaction holds.
      def wait_for(import)
        Timeout.timeout(10) { sleep(0.05) until !import.alive? || waiting_for_lock? }
      end

      def waiting_for_lock?
        ActiveRecord::Base.connection.select_value(<<~SQL.squish).positive?
          SELECT count(*) FROM pg_stat_activity WHERE datname = current_database() AND wait_event_type = 'Lock'
        SQL
      end

      # Reads as the site does, failing rather than waiting for a lock.
      def read(&)
        ActiveRecord::Base.transaction do
          ActiveRecord::Base.connection.execute("SET LOCAL lock_timeout = '1s'")
          yield
        end
      end

      it 'waits for a transaction adding a prosecutor, and so adds the prosecutor only once' do
        other.begin_db_transaction
        other.execute(<<~SQL.squish)
          INSERT INTO prosecutors (name, name_parts, created_at, updated_at)
          VALUES ('JUDr. Ingrid Adamcová', '{}', now(), now())
        SQL

        import = start_import
        wait_for(import)
        other.commit_db_transaction
        import.join

        expect(Prosecutor.where(name: 'JUDr. Ingrid Adamcová').count).to eq(1)
        expect(Prosecutor.count).to eq(27)
      end

      it 'lets the site read the prosecutors and the offices while it holds them locked' do
        # The same list, added and not committed by the other transaction, holds the import once it locked the tables.
        digest = Digest::MD5.hexdigest(fixture('genpro_gov_sk/prosecutors/list-page-1.pdf').binread)
        other.begin_db_transaction
        other.execute(<<~SQL.squish)
          INSERT INTO genpro_gov_sk_prosecutors_lists (data, digest, file, created_at, updated_at)
          VALUES ('[]', #{other.quote(digest)}, '', now(), now())
        SQL

        import = start_import
        wait_for(import)

        expect { read { [Office, Prosecutor, Appointment, Employee].each(&:first) } }.not_to raise_error

        other.rollback_db_transaction
        import.join

        expect(Prosecutor.count).to eq(27)
      end
    end
  end
end

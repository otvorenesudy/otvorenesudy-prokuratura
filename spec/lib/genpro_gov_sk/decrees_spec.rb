require 'rails_helper'

RSpec.describe GenproGovSk::Decrees, webmock: :disabled do
  describe '.import' do
    it 'fetches all pages and calls import jobs for each decree' do
      allow(GenproGovSk::ImportPdfDecreeJob).to receive(:perform_later)
      allow(GenproGovSk::ImportRtfDecreeJob).to receive(:perform_later)

      call_count = 0
      allow(Curl).to receive(:get) do |url|
        call_count += 1

        if call_count == 1
          landing_html = File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'decrees', 'page_1.html'))
          double(body_str: landing_html)
        else
          mock_html = <<~HTML
            <html>
              <body>
                <div class="tx-tempest-applications">
                  <table class="govuk-table">
                    <tbody>
                      <tr>
                        <td>
                          <a href="/download/uznesenie/2025/11/test_#{call_count}.pdf">TEST/#{call_count}/2025<br>(pdf, 100 KB)</a>
                        </td>
                        <td>19. 11. 2025</td>
                        <td>19. 11. 2025</td>
                        <td>1 Pv #{call_count}/25</td>
                        <td>Test Resolution</td>
                        <td>Test Means</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </body>
            </html>
          HTML
          double(body_str: mock_html)
        end
      end

      described_class.import

      expect(Curl).to have_received(:get).at_least(2).times
      expect(GenproGovSk::ImportPdfDecreeJob).to have_received(:perform_later).at_least(:once)
    end

    it 'raises an error for unknown decree file type' do
      mock_html = <<~HTML
        <html>
          <body>
            <div class="tx-tempest-applications">
              <table class="govuk-table">
                <tbody>
                  <tr>
                    <td>
                      <a href="/download/uznesenie/2025/11/test.docx">TEST/1/2025<br>(docx, 100 KB)</a>
                    </td>
                    <td>19. 11. 2025</td>
                    <td>19. 11. 2025</td>
                    <td>1 Pv 1/25</td>
                    <td>Test Resolution</td>
                    <td>Test Means</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </body>
        </html>
      HTML

      landing_html = '<html><body><ul class="govuk-pagination__list"><li>1</li></ul></body></html>'

      call_count = 0
      allow(Curl).to receive(:get) do |url|
        call_count += 1
        if call_count == 1
          double(body_str: landing_html)
        else
          double(body_str: mock_html)
        end
      end

      expect { described_class.import }.to raise_error(ArgumentError, /Unknown decree type/)
    end

    it 'calls ImportRtfDecreeJob for RTF files' do
      allow(GenproGovSk::ImportPdfDecreeJob).to receive(:perform_later)
      allow(GenproGovSk::ImportRtfDecreeJob).to receive(:perform_later)

      rtf_html = <<~HTML
        <html>
          <body>
            <div class="tx-tempest-applications">
              <table class="govuk-table">
                <tbody>
                  <tr>
                    <td>
                      <a href="/download/uznesenie/2025/11/test.rtf">TEST/1/2025<br>(rtf, 50 KB)</a>
                    </td>
                    <td>19. 11. 2025</td>
                    <td>19. 11. 2025</td>
                    <td>1 Pv 1/25</td>
                    <td>Test Resolution</td>
                    <td>Test Means</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </body>
        </html>
      HTML

      landing_html = '<html><body><ul class="govuk-pagination__list"><li>1</li></ul></body></html>'

      call_count = 0
      allow(Curl).to receive(:get) do |url|
        call_count += 1
        if call_count == 1
          double(body_str: landing_html)
        else
          double(body_str: rtf_html)
        end
      end

      described_class.import

      expect(GenproGovSk::ImportRtfDecreeJob).to have_received(:perform_later).at_least(:once)
    end
  end
end

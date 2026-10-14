require "rails_helper"

describe SanitizesUserHtml do
  let(:malicious) do
    '<p>Hallo</p><img src=x onerror=alert(1)><a href="javascript:alert(1)">klik</a><script>alert(1)</script>'
  end

  it "schoont de beschrijving van een begrotingsidee op bij opslaan" do
    investment = create(:budget_investment, description: malicious)

    expect(investment.reload.description).not_to include("onerror", "<img", "javascript:", "<script")
    expect(investment.description).to include("<p>Hallo</p>", "klik")
  end

  it "schoont ook teksten via translations_attributes op" do
    investment = create(:budget_investment)
    investment.update!(translations_attributes: [{ id: investment.translations.first.id,
                                                   locale: investment.translations.first.locale,
                                                   description: malicious }])

    expect(investment.reload.description).not_to include("onerror", "javascript:")
  end

  it "laat toegestane opmaak ongewijzigd" do
    html = '<p>Tekst met <strong>vet</strong></p><ul><li>punt</li></ul><a href="https://example.org">link</a>'
    investment = create(:budget_investment, description: html)

    expect(investment.reload.description).to eq html
  end

  it "schoont voorstellen, debatten en wetgevingsvoorstellen op" do
    [create(:proposal, description: malicious),
     create(:debate, description: malicious),
     create(:legislation_proposal, description: malicious)].each do |record|
      expect(record.reload.description).not_to include("onerror", "javascript:", "<script")
    end
  end

  it "raakt velden van beheerders niet" do
    phase = create(:budget).phases.first
    phase.update!(description: '<p><img src="/foto.png" alt="foto"></p>')

    expect(phase.reload.description).to include("<img")
  end
end

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

  it "schoont antwoordopties van peilingen op" do
    option = create(:poll_question_option, description: malicious)

    expect(option.reload.description).not_to include("onerror", "javascript:", "<script")
    expect(option.description).to include("<p>Hallo</p>")
  end

  it "schoont alle talen op, ook een tweede taal via de setter" do
    investment = create(:budget_investment)
    Globalize.with_locale(:es) { investment.update!(title: "Título en español", description: malicious) }

    spanish = investment.translations.find_by(locale: "es")
    expect(spanish.description).not_to include("onerror", "javascript:", "<script")
  end

  it "schoont een nieuwe taal via translations_attributes op" do
    investment = create(:budget_investment)
    new_translation = { locale: "es", title: "Título en español", description: malicious }
    investment.update!(translations_attributes: [new_translation])

    spanish = investment.translations.find_by(locale: "es")
    expect(spanish.description).not_to include("onerror", "javascript:", "<script")
  end

  it "schoont antwoordopties op die via de geneste route van het voorsteldashboard binnenkomen" do
    option = create(:poll_question_option)
    question = option.question

    options = [{ id: option.id, description: malicious }]
    question.poll.update!(questions_attributes: [{ id: question.id, question_options_attributes: options }])

    expect(option.reload.description).not_to include("onerror", "javascript:", "<script")
  end

  it "schoont de beschrijving van een peiling op met de beheerderssanitizer" do
    html = '<p>Intro</p><img src="/foto.png" alt="foto" onerror="alert(1)"><script>alert(1)</script>'
    poll = create(:poll)
    poll.update!(description: html)

    expect(poll.reload.description).not_to include("onerror", "<script")
    expect(poll.description).to include("<p>Intro</p>", '<img src="/foto.png" alt="foto">')
  end

  it "schoont een peiling uit het voorsteldashboard streng op" do
    poll = create(:poll, related: create(:proposal))
    html = '<p>Intro</p><img src="/foto.png" alt="foto"><iframe src="https://example.org"></iframe>'
    poll.update!(description: html)

    expect(poll.reload.description).to eq "<p>Intro</p>"
  end

  it "schoont ook op bij opslaan zonder validatie" do
    investment = create(:budget_investment)
    investment.description = malicious
    investment.save!(validate: false)

    expect(investment.reload.description).not_to include("onerror", "javascript:", "<script")
  end

  it "raakt velden van beheerders niet" do
    phase = create(:budget).phases.first
    phase.update!(description: '<p><img src="/foto.png" alt="foto"></p>')

    expect(phase.reload.description).to include("<img")
  end
end

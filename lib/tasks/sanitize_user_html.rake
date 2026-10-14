namespace :sanitize_user_html do
  desc "Schoont bestaande inwonersteksten op (droogloop; WRITE=1 om te schrijven)"
  task existing: :environment do
    write = ENV["WRITE"] == "1"
    sanitizer = WYSIWYGSanitizer.new

    targets = [
      Budget::Investment.translation_class,
      Proposal.translation_class,
      Debate.translation_class,
      Legislation::Proposal
    ]

    targets.each do |klass|
      ids = []
      klass.unscoped.where.not(description: [nil, ""]).find_each do |record|
        clean = sanitizer.sanitize(record.description)
        next if clean == record.description

        ids << record.id
        record.update_column(:description, clean) if write
      end

      puts "#{klass.name}: #{ids.size} #{write ? "opgeschoond" : "zouden veranderen"} #{ids.first(50).inspect}"
    end
  end
end

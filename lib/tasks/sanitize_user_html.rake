module SanitizeUserHtmlTask
  # [model of vertaalklasse, sanitizer] — dezelfde sanitizer als het model bij opslaan gebruikt.
  TARGETS = lambda do
    [
      [Budget::Investment.translation_class, WYSIWYGSanitizer],
      [Proposal.translation_class, WYSIWYGSanitizer],
      [Debate.translation_class, WYSIWYGSanitizer],
      [Legislation::Proposal, WYSIWYGSanitizer],
      [Poll::Question::Option.translation_class, WYSIWYGSanitizer],
      [Poll.translation_class, AdminWYSIWYGSanitizer]
    ]
  end
end

namespace :sanitize_user_html do
  desc "Schoont bestaande inwonersteksten op. Droogloop; WRITE=1 schrijft, na een backup van de " \
       "oude waarden in tmp/sanitize_user_html-<tijd>.jsonl (ook het audit-spoor: update_all " \
       "slaat audits, updated_at en de zoekindex over)"
  task existing: :environment do
    write = ENV["WRITE"] == "1"
    backup_path = Rails.root.join("tmp", "sanitize_user_html-#{Time.current.strftime("%Y%m%d-%H%M%S")}.jsonl")
    changes = []

    SanitizeUserHtmlTask::TARGETS.call.each do |klass, sanitizer_class|
      sanitizer = sanitizer_class.new
      ids = []
      klass.unscoped.where.not(description: [nil, ""]).find_each do |record|
        clean = sanitizer.sanitize(record.description)
        next if clean == record.description

        ids << record.id
        changes << { klass: klass.name, id: record.id, old: record.description, new: clean }
      end

      puts "#{klass.name}: #{ids.size} #{write ? "op te schonen" : "zouden veranderen"} #{ids.first(50).inspect}"
    end

    next unless write && changes.any?

    File.open(backup_path, "w", 0o600) { |f| changes.each { |c| f.puts(c.to_json) } }
    puts "Oude waarden bewaard in #{backup_path} (#{changes.size} regels)"

    updated = 0
    ActiveRecord::Base.transaction do
      changes.each do |c|
        # Alleen schrijven als de tekst sinds het lezen niet is gewijzigd.
        updated += c[:klass].constantize.unscoped
                            .where(id: c[:id], description: c[:old])
                            .update_all(description: c[:new])
      end
    end
    puts "#{updated} teksten opgeschoond, #{changes.size - updated} overgeslagen (tussentijds gewijzigd)"
  end

  desc "Zet oude waarden terug uit een backupbestand van :existing (FILE=pad); alleen teksten die sindsdien niet zijn gewijzigd"
  task restore: :environment do
    path = ENV.fetch("FILE")
    rows = File.readlines(path).map { |line| JSON.parse(line) }
    restored = 0
    ActiveRecord::Base.transaction do
      rows.each do |row|
        restored += row["klass"].constantize.unscoped
                                .where(id: row["id"], description: row["new"])
                                .update_all(description: row["old"])
      end
    end
    puts "#{restored} teksten teruggezet uit #{path}, #{rows.size - restored} overgeslagen (sindsdien gewijzigd)"
  end
end

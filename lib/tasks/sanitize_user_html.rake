namespace :sanitize_user_html do
  def sanitize_user_html_targets
    [
      Budget::Investment.translation_class,
      Proposal.translation_class,
      Debate.translation_class,
      Legislation::Proposal,
      Poll::Question::Option.translation_class
    ]
  end

  desc "Schoont bestaande inwonersteksten op (droogloop; WRITE=1 om te schrijven, eerst een backup van de oude waarden)"
  task existing: :environment do
    write = ENV["WRITE"] == "1"
    sanitizer = WYSIWYGSanitizer.new
    backup_path = Rails.root.join("tmp", "sanitize_user_html-#{Time.current.strftime("%Y%m%d-%H%M%S")}.jsonl")
    changes = []

    sanitize_user_html_targets.each do |klass|
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

    File.open(backup_path, "w") { |f| changes.each { |c| f.puts(c.to_json) } }
    puts "Oude waarden bewaard in #{backup_path} (#{changes.size} regels)"

    ActiveRecord::Base.transaction do
      changes.each do |c|
        c[:klass].constantize.unscoped.where(id: c[:id]).update_all(description: c[:new])
      end
    end
    puts "#{changes.size} teksten opgeschoond"
  end

  desc "Zet oude waarden terug uit een backupbestand van :existing (FILE=pad)"
  task restore: :environment do
    path = ENV.fetch("FILE")
    rows = File.readlines(path).map { |line| JSON.parse(line) }
    ActiveRecord::Base.transaction do
      rows.each do |row|
        row["klass"].constantize.unscoped.where(id: row["id"]).update_all(description: row["old"])
      end
    end
    puts "#{rows.size} teksten teruggezet uit #{path}"
  end
end

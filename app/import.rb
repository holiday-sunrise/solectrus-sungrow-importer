require_relative 'flux_writer'
require_relative 'solectrus_sungrow_record'

class Import
  def self.run(config:)
    import = new(config:)

    puts "Importing data from #{config.import_folder} ..."

    count = 0
    Dir
      .glob("#{config.import_folder}/**/*.csv")
      .each do |filename|
        import.process(filename)
        count += 1
      end

    puts "Imported #{count} files\n\n"

    count
  end

  def initialize(config:)
    @config = config
  end

  attr_reader :config

  def process(filename)
    print "Importing #{filename}... "

    count = 0
    file = File.read(filename)
    file = file.tr("\n", '')
    records =
      CSV
        .parse(file, headers: true, col_sep: ',', row_sep: "\r")
        .map do |row|
          count += 1

          SungrowRecord.new(row).to_h
        end

    return unless count.positive?

    FluxWriter.push(config:, records:)
    puts "#{count} points imported"
    return unless config.import_pause.positive?

    puts "Pausing for #{config.import_pause} seconds..."
    sleep(config.import_pause)
  end
end

#!/usr/bin/env ruby

require 'dotenv/load'
require_relative 'config'
require_relative 'import'

# Flush output immediately
$stdout.sync = true

puts 'Sungrow CSV importer for SOLECTRUS, ' \
       "Version #{ENV.fetch('VERSION', '<unknown>')}, " \
       "built at #{ENV.fetch('BUILDTIME', '<unknown>')}"
puts 'https://github.com/holiday-sunrise/solectrus-sungrow-importer.git'
puts 'Copyright (c) 2020-2023 Georg Ledermann, Rainer Drexler, released under the MIT License'
puts "\n"

config = Config.from_env

puts "Using Ruby #{RUBY_VERSION} on platform #{RUBY_PLATFORM}"
puts "Pushing to InfluxDB at #{config.influx_url}, bucket #{config.influx_bucket}"
puts "\n"

Import.run(config:)

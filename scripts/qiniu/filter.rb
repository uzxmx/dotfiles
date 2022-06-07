#!/usr/bin/env ruby

require 'time'
require 'json'

def usage
  puts <<EOF
Usage: qiniu filter

Filter listed files. You must list all files first by 'qiniu list -a' before
executing this command.

Options:
  -s <start-time> the start time to filter for the upload time
  -e <end-time> the end time to filter for the upload time
  -t <mime-type> the mime type prefix to filter

Examples:
  qiniu filter -s 2021-09-15
  qiniu filter -s "2021-09-30 16:28:00" -e "2021-10-30 16:28:00" -t image
EOF
end

i, argc = 0, ARGV.size
while i < argc
  case ARGV[i]
  when '-s'
    i += 1
    start_time = Time.parse(ARGV[i])
  when '-e'
    i += 1
    end_time = Time.parse(ARGV[i])
  when '-t'
    i += 1
    mime_type = ARGV[i]
  else
    usage
    exit
  end
  i += 1
end

files = Dir.glob('*.json')
if files.size == 0
  puts 'No json files found. You may need to run `qiniu list -a` to dump json files.'
  exit 1
end

first = true
files.each do |file|
  json = JSON.parse(File.read(file))
  json['items'].each do |item|
    next if mime_type && !item['mimeType'].start_with?(mime_type)

    time = Time.at(item['putTime'] / 10000000)
    next if start_time && time < start_time
    next if end_time && time > end_time

    if first
      first = false
      puts "Key\tMime Type\tPut Time"
    end

    puts "#{item['key']}\t#{item['mimeType']}\t#{time}"
  end
end

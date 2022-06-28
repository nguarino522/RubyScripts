#!/usr/bin/env ruby

file = File.open("/etc/passwd")

file.readlines.each do |line|
	user_entry = line.split(":")
	puts "#{user_entry[0]}:#{user_entry[5]}"
end

#!/usr/bin/env ruby

#set file to pull usernames and home directories from
file = File.open("/etc/passwd")

#reach through each line, separate using split method and output first and sixth entries in set array
file.readlines.each do |line|
	user_entry = line.split(":")
	puts "#{user_entry[0]}:#{user_entry[5]}"
end

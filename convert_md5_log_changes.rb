#!/usr/bin/env ruby

require 'digest'

script_file_command = `/home/nguarino/list_username_homedirectory.rb`
usernames = script_file_command.split

usernames.each do |u|
	puts Digest::MD5.hexdigest(u)
end

#if(File.file?('/var/log/current_users'))
#	puts "exists"
#elsif(File.

#end

#File.open("/var/log/current_users", "mode"

puts Digest::MD5.hexdigest("nguarino:/home/nguarino")

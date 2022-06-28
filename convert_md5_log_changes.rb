#!/usr/bin/env ruby

require 'digest'

script_file_command = `/home/nguarino/list_username_homedirectory.rb`
usernames = script_file_command
hash = Digest::MD5.hexdigest(usernames)

if not File.exists?("/var/log/current_users")
	File.open("/var/log/current_users", "w") do |f|
		f << hash
	end
else 
	old_hash = `cat /var/log/current_users`
	if old_hash != hash
		File.open("/var/log/current_users", "w") do |f|
			f << hash
		end
		File.open("/var/log/user_changes", "a") do |f|
			date = `date`
			date.delete!("\n")
			f << "#{date} changes occurred"
		end
	else
		exit
	end
end

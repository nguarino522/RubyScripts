#!/usr/bin/env ruby

require 'digest'

script_file_command = `/home/nguarino/list_username_homedirectory.rb`
usernames = script_file_command
hash = Digest::MD5.hexdigest(usernames)

unless File.file?('/var/log/current_users')
       
#elsif(File.



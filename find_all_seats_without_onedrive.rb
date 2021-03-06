#!/usr/bin/env ruby

#pull in class and objects from rails environment
require File.expand_path('/mnt/backupify-production/current/script/script_helper',  __FILE__)
script_env(:rails)

#decalare and require anything we need
require 'csv'
@seat_ids = Array.new
@missing_onedrive_seat_list = Array.new


#grab customer id, alternatively can set it manually and run script manually piece by piece
puts 'Please input a customer ID:'
cust_id = gets.chomp
c = Customer.find cust_id

#assign array to grabbed list of office 365 seat ids
@seat_ids = c.office365_seat_ids

#iterate through the arary to determine which seats have the onedrive service or not
#grab every seat principal name and output to an array
@seat_ids.each do |i|
    seat = Seat.find i
    service = seat.services.where(:type => "Office365OneDriveService")
    if service.present? == false then
        principal_name = seat.principal_name
        @missing_onedrive_seat_list << principal_name
    end
end

#output array to CSV
CSV.open("users_missing_onedrive.csv", "w") do |i|
    @missing_onedrive_seat_list.each do |j|
        i << [j]
    end
end

#email to specified inputed email address the CSV sheet created
puts 'Please list an email to send the CSV sheet of users to:'
user_email = gets.chomp

def send_csv(user_email, csv)
    attachments['users_missing_onedrive.csv'] = {mime_type: 'text/csv', content: csv}
    mail(to: user_email, subject: 'My subject', body: "List of seats which currently don't have the OneDrive service added.")
end
#!/usr/bin/env ruby

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
        i << [x]
    end
end

#email to specified inputed email address the CSV sheet created
puts 'Please list an email to send the CSV sheet of users to:'
user_email = gets.chomp
attachments['users_missing_onedrive.csv'] = {mime_type: 'text/csv', content: Order.orders_csv(logged_in_user, orders)}
mail(to: user_email.email, subject: 'CSV sheet of users missing One Drive services')
#!/usr/bin/env ruby

#grab customer passed in through bash shell
c = Customer.find ARGV[0]

#decalre array and assign to grabbed list of office 365 seat ids
@seat_ids = Array.new
@seat_ids = c.office365_seat_ids

#iterate through the arary to determine which seats have the onedrive service or not
#grab every seat principal name and output to an array
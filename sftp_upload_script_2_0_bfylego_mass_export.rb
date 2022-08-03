#!/usr/bin/env ruby

# script to pull in CSV sheet (delimited by commas) with service export information, copy and rename to 'export_upload' directory, 
# upload to SFTP location using bash script with secure credentials, then finally delete from 'export_upload' directory
# usage: make an executable '.rb' file in linxu cli and run, will prompt for file location of CSV file

require 'csv'

def perform
    puts "Please enter file path and file name of such as /root/nguarino/serviceExportInfo.csv to a CSV file that is comma delimited: "
    csv_file = gets.chomp
    service_export_info = CSV.read("#{csv_file}")
    puts "Please list the customer ID of the account you need to pull export files from: "
    customer_id = gets.chomp
    counter = service_export_info.count
    grab_rename_store_zipfile(service_export_info, customer_id)
    puts "script has finished running"
end

def grab_rename_store_zipfile(serv_exp_info, cid)
    counter = serv_exp_info.count
    serv_exp_info.each do |e|
        puts "#{counter} entries left to iterate through"
        app_type = e[0]
        name = e[1].split
        email = e[2]
        last_backup_date = e[3]
        export_zip_name = e[4]
        if export_zip_name == "NULL"
            counter = counter - 1
            next
        else
            system("cp /datto/array1/bfyData/#{cid}/#{app_type}/exports/#{export_zip_name}.zip /datto/array1/bfyData/export_upload/#{app_type}_#{name[0]}_#{name[1]}.zip")
            puts "export file copied and renamed from export directory into export_upload directory, attempting to upload to sftp location"
            system("sh sftpbashscriptupload.sh /datto/array1/bfyData/export_upload/#{app_type}_#{name[0]}_#{name[1]}.zip")
            puts "export upload to sftp location successful"
            File.delete("/datto/array1/bfyData/export_upload/#{app_type}_#{name[0]}_#{name[1]}.zip")
            puts "export file removed from export_upload directory, moving on to next export"
            counter = counter - 1
        end           
    end
end

perform
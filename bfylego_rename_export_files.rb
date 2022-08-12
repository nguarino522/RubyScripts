#!/usr/bin/env ruby

# script to pull in CSV sheet (delimited by commas) with service export information, copy and rename to 'export_upload' directory
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
        mailbox = e[5]
        sp_name = e[6]
        if last_backup_date == "NULL"
            counter = counter - 1
            puts "attempting to copy #{e}"
            puts "no valid snapshot so wasn't exported, next"
            next
        else
            if app_type == "Office365Exchange" || app_type == "Office365OneDrive"
                counter = counter - 1
                if File.exists?("'/datto/array1/bfyData/#{cid}/export_upload/#{app_type}_#{name[0]}_#{name[1]}.zip'")
                    puts "attempting to copy #{e} but detected same name already"
                else
                    puts "attempting to copy #{e}"
                    system("mv /datto/array1/bfyData/#{cid}/export_upload/#{export_zip_name}.zip '/datto/array1/bfyData/#{cid}/export_upload/#{app_type}_#{name[0]}_#{name[1]}.zip'")
                    puts "export file renamed, moving to next export file"
                end
            end
            if app_type == "Office365Teams"
                counter = counter - 1
                if File.exists?("'/datto/array1/bfyData/#{cid}/export_upload/#{app_type}_#{name[0]}_#{name[1]}.zip'")
                    puts "attempting to copy #{e} but detected same name already"
                else
                    puts "attempting to copy #{e}"
                    system("mv /datto/array1/bfyData/#{cid}/export_upload/#{export_zip_name}.zip '/datto/array1/bfyData/#{cid}/export_upload/#{app_type}_#{mailbox}.zip'")
                    puts "export file renamed, moving to next export file"
                end
            end
            if app_type == "Office365SharePoint"
                counter = counter - 1
                if File.exists?("'/datto/array1/bfyData/#{cid}/export_upload/#{app_type}_#{name[0]}_#{name[1]}.zip'")
                    puts "attempting to copy #{e} but detected same name already"
                else
                    puts "attempting to copy #{e}"
                    system("mv /datto/array1/bfyData/#{cid}/export_upload/#{export_zip_name}.zip '/datto/array1/bfyData/#{cid}/export_upload/#{app_type}_#{sp_name}.zip'")
                    puts "export file renamed, moving to next export file"
                end
            end
        end           
    end
end

perform
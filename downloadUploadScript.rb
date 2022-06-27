#!/usr/bin/env ruby


#this script will pull in a CSV of download links and other service information 
#from that it will download each export file and name based on email and specific naming convention
#from there it will call upon a secure bash script file to upload a file share using SFTP then remove the local file copy

#!/usr/bin/env ruby

require 'csv'

download_links = CSV.read("/mnt/citymdExportStorage/serviceDownloadLinks.csv")

counter = download_links.count

download_links.each do |d|
 begin
  puts "#{counter} services left to upload"
  download_link = d[3]
  zip_filename = "#{d[2]}_googledrive.zip"
  zip_filepath = "/mnt/citymdExportStorage/#{d[2]}_googledrive.zip"
  system("wget -O #{zip_filepath} '#{download_link}'")
  puts "export download from Azure successful"
  system("sh sftpbashscriptupload.sh #{zip_filepath}")
  puts "export upload to sftp location successful"
  File.delete("/mnt/citymdExportStorage/#{zip_filename}")
  puts "export file deleted from rails console server, moving on to next export"
  counter = counter - 1
 rescue => e
  puts e
 end
end

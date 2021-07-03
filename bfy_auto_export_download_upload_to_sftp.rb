class AutoSFTPMultiServiceExportUploader

#will need to or want to have user input below, etc. so its not in code the direct connection
server = "<redacted>"
username = "<redacted>"
password = "<redacted">
mse = MultiServiceExport.find(<redacted>)
investigate = []
@service_complete_tracker_array = []

def find_filename(service)
    download_url = service.export_runs.first.archive_url
    if download_url == nil
        puts "no current download link for export run so no data found for service #{service.id}"
        return
    end
    regex = /([^\/]*)\?/
    name = regex.match(download_url)[1]
    filename = URI.unescape(name)
end

def get_current_available_export_download_links(mse, service_complete_tracker_array)
    services = []
    download_links = []
    fess_successful = mse.full_export_service_states.where(status: "successful");
    fess_successful.each do |fess|
        if service_complete_tracker_array.exclude? fess.service_id
            serv = Service.find fess.service_id
            services << serv
        end
    end;
    services.each do |s|
        download_link = s.export_runs.first.archive_url
        download_links << download_link
    end
end

services_successful.each do |s|
	begin
		download_link = s.export_runs.first.archive_url
		file_name = find_filename(s)
		if file_name != nil
			open(download_link) do |file1|
				File.open("/tmp/nguarino/#{file_name}", "wb") do |file2|
					file2.write(file1.read)
				end
			end
			Net::SFTP.start('<redacted>', '<redacted>', :password => '<redacted>') do |sftp|
				sftp.upload!("/tmp/nguarino/#{file_name}", "/E:/datto_data/#{file_name}")
			end
			File.delete("/tmp/nguarino/#{file_name}")
			puts "service #{s.id} has successfully been uploaded to sftp location"
		end
	rescue => e
		puts "service #{s.id} has failed with the following error during script execution:"
		puts e
		investigate << s.id
	end
end;

services_successful.each do |s|
	begin
		download_link = s.export_runs.first.archive_url
		file_name = find_filename(s)
		if file_name != nil
			open(download_link) do |file1|
				File.open("/tmp/nguarino/#{file_name}", "wb") do |file2|
					file2.write(file1.read)
				end
			end
			Net::SFTP.start('<redacted>', '<redacted>', :password => '<redacted>') do |sftp|
				sftp.upload!("/tmp/nguarino/#{file_name}", "/E:/datto_data/#{file_name}")
			end
			File.delete("/tmp/nguarino/#{file_name}")
			puts "service #{s.id} has successfully been uploaded to sftp location"
		end
	rescue => e
		puts "service #{s.id} has failed with the following error during script execution:"
		puts e
		investigate << s.id
	end
end;


services.each do |s|
	begin
		download_link = s.export_runs.first.archive_url
		file_name = find_filename(s)
		if file_name != nil && system("grep #{file_name} /tmp/nguarino/successfully_uploaded_exports.txt") == false
			open(download_link) do |file1|
				File.open("/tmp/nguarino/#{file_name}", "wb") do |file2|
					file2.write(file1.read)
				end
			end
			system("cd /tmp/nguarino && sh sftpbashscriptupload.sh #{file_name}")
			File.delete("/tmp/nguarino/#{file_name}")
			puts "service #{s.id} has successfully been uploaded to sftp location"
		end
	rescue => e
		puts "service #{s.id} has failed with the following error during script execution:"
		puts e
		investigate << s.id
	end
end;


services_successful.each do |s|
	begin
		download_link = s.export_runs.first.archive_url
		file_name = find_filename(s)
		if file_name != nil
			open(download_link) do |file1|
				File.open("/tmp/nguarino/#{file_name}", "wb") do |file2|
					file2.write(file1.read)
				end
			end
			system("cd /tmp/nguarino && sh sftpbashscriptupload.sh #{file_name}")
			File.delete("/tmp/nguarino/#{file_name}")
			puts "service #{s.id} has successfully been uploaded to sftp location"
		end
	rescue => e
		puts "service #{s.id} has failed with the following error during script execution:"
		puts e
		investigate << s.id
	end
end;

services_successful.each do |s|
	begin
		download_link = s.export_runs.first.archive_url
		file_name = find_filename(s)
		if file_name != nil
			open(download_link) do |file1|
				File.open("/tmp/nguarino/#{file_name}", "wb") do |file2|
					file2.write(file1.read)
				end
			end
			Net::SFTP.start('<redacted>', '<redacted>', :password => '<redacted>') do |sftp|
				sftp.upload!("/tmp/nguarino/#{file_name}", "/E:/datto_data/#{file_name}")
			end
			File.delete("/tmp/nguarino/#{file_name}")
			puts "service #{s.id} has successfully been uploaded to sftp location"
		end
	rescue => e
		puts "service #{s.id} has failed with the following error during script execution:"
		puts e
		investigate << s.id
	end
end;


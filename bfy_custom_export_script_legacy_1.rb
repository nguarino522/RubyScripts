class CustomExporter
    require 'fileutils'
    attr_accessor :service, :service_path, :errors, :zip_filename,
                  :archive_url, :file_name, :used_file_names
    def initialize(service, file_name = nil)
      @used_file_names = Hash.new { |h, k| h[k] = 0 }
      @service = service
      select_data_store service
      @file_name = file_name || service.account_name
      @service_path = "/mnt/exports/" + (file_name || service.account_name) + "/"
      @errors = []
      @zip_filename = @service_path[0..-2] + '.zip'
    end
    def process
      puts "Exporting files to: " + @service_path
      counter = 0
      item_count = @service.data_interface.all.count
      FileUtils.mkdir_p(@service_path) unless File.directory?(@service_path)
      puts "Service type: " + @service.type
      @service.data_interface.all.each do |message|
        counter += 1
        puts "\n#{counter}/#{item_count}"
        write_contents_to_file(message.id)
      end
      #todo zip
      breaker = false
      if @errors.count == 0
        puts "Fetching objects complete. No errors.  Beginning zip"
      else
        puts "ERRORS! Fix it!"
        binding.pry
      end
      return if breaker
      zip_result = zip_export
      if zip_result
        print "Zip complete. "
      else
        puts "ERRORS! Fix it!"
        binding.pry
      end
      return if breaker
      upload_to_s3
    end
    #use gsub for problem characters in subjects
    def format_filename(filename)
      # TODO: Handle extension
      filename.gsub(/[<>:"\/\\|\?\*']/, "")
    end
    def get_path_and_name(filename)
      path_and_name = @service_path
      path_and_name += format_filename(filename)
      times_used = @used_file_names[path_and_name]
      @used_file_names[path_and_name] += 1
      if times_used > 0
        ext_start = path_and_name.rindex(".")
        path_and_name = path_and_name[0...ext_start] + "(#{times_used})" + path_and_name[ext_start..-1]
      end
      path_and_name
    end
    def write_google_contents_to_file(datum_key)
      begin
        select_data_store @service
        datum = @service.metadatum_class.find(*datum_key)
        path_and_name = get_path_and_name(datum.ui_content_filename)
        puts "Writing file: " + path_and_name
        File.open(path_and_name, 'wb') do |f|
          datum.content do |chunk|
            print "."
            f << chunk
          end
        end
      rescue => e
        puts e
        @errors << [datum_key, e]
      end
    end
    def write_o365_contents_to_file(datum_key)
      begin
        select_data_store @service
        datum = @service.data_interface.find(datum_key)
        path_and_name = get_path_and_name(datum.subject + ".eml")
        puts "Writing file: " + path_and_name
        puts "datum.content: #{datum.content}"
        File.open(path_and_name, 'wb') do |f|
          print "."
          f << datum.content
        end
      rescue => e
        puts e
        @errors << [datum_key, e]
      end
    end
    def write_contents_to_file(message_id)
      if @service.type == "Office365MailService"
        write_o365_contents_to_file(message_id)
      elsif @service.type[0...6] == "Google"
        write_google_contents_to_file(message_id)
      else
        @errors << [message_id, "Unknown service type: " + @service.type]
      end
    end
    def zip_export
      puts "Creating zip file: " + zip_filename
      Kernel.system("zip -qr #{zip_filename} #{file_name}", :chdir => "/exports")
      # zip_command = "zip -qr #{zip_filename} #{service_path[0..-2]}"
      # `#{zip_command}`
    end
    def select_data_store(s)
      if s.cassandra_backend == 'ec2'
        Backupify::CassUtil::Selector.use_old_datastores
      else
        Backupify::CassUtil::Selector.use_new_datastores
      end
    end
    def upload_to_s3
      begin
        puts "Uploading to s3"
        destination = Jobs::Generic::Util::ExportUpload.new(service.s3_bucket, service)
        filename_obj = Storage::Utils::Filename.new(name: file_name,
                                                    path: service.storage_path,
                                                    extension: 'zip')
        zip_file = File.new(@zip_filename)
        Storage::Adapters::S3Adapter.configuration.long_timeout = 1.day
        destination.upload(filename_obj, zip_file)
        @archive_url = destination.authenticated_url(filename_obj, :expires_in => 1.month)
        puts "Complete! Archive_url: #{@archive_url}"
        puts "size: #{zip_file.size.to_formatted_s(:human_size)}"
      rescue => e
        binding.pry
      end
    end
    def print_scp_string
      puts "scp root@qlessworker99.backupify.com:#{zip_filename} ~/Desktop"
    end
  end
  def select_data_store(s)
    if s.cassandra_backend == 'ec2'
      Backupify::CassUtil::Selector.use_old_datastores
    else
      Backupify::CassUtil::Selector.use_new_datastores
    end
  end
  # Helper method that actually kicks off the export
  def ce_all(service)
    # change timeouts for S3 and swift
    Storage::Adapters::S3Adapter.configuration.long_timeout = 1.day
    Storage::Adapters::SwiftAdapter.configuration.long_timeout = 1.day
    select_data_store service
    ce = CustomExporter.new(service)
    ce.process
  end
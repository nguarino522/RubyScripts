class ServiceExporter
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
      data_count = service.data_count
      puts "Exporting files to: " + service_path
      counter = 0
      FileUtils.mkdir_p(service_path) unless File.directory?(service_path)
      puts "Service type: " + @service.type
      service.metadatum_class.find_each_key(service.id) do |key|
        counter += 1
        puts
        puts "#{counter}/#{data_count}"
        p key
        write_contents_to_file(key)
      end
      #todo zip
      breaker = false
      if errors.count == 0
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
    def write_contents_to_file(datum_key)
      begin
        s = Service.find(datum_key.first)
        select_data_store s
        datum = s.metadatum_class.find(datum_key[0], datum_key[1].force_encoding("ASCII-8BIT"))
        path_and_name = service_path
        path_and_name += format_filename(datum.ui_content_filename)
        times_used = used_file_names[path_and_name]
        if times_used > 0
          dot_position = path_and_name.rindex(".")
          if dot_position > path_and_name.rindex("/")
            # filename part has dot, put (n) before dot
            path_and_name = path_and_name[0...dot_position] + "(#{times_used})" + path_and_name[dot_position..-1]
          else
            #filename part has no dot, put (n) at and
            path_and_name += "(#{times_used})"
          end
        end
        puts "Writing file: " + path_and_name
        File.open(path_and_name, 'wb') do |f|
          datum.content do |chunk|
            print "."
            f << chunk
          end
        end
        used_file_names[path_and_name] += 1
      rescue => e
        puts e
        errors << [datum_key, e]
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
      puts "Uploading to s3"
      # destination = Jobs::Generic::Util::S3Upload.new(service.s3_bucket)
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
  def ce_from_service(s)
    # change timeouts for S3 and swift
    Storage::Adapters::S3Adapter.configuration.long_timeout = 30.days
    Storage::Adapters::SwiftAdapter.configuration.long_timeout = 30.days
    select_data_store s
    se = ServiceExporter.new(s)
    se.process
  end
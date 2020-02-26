def export_list(id)
    retry_opts = {
      :on => [CassandraThrift::TimedOutException, Timeout::Error],
      :times => 6,
      :interval => lambda { |attempts| 2.seconds ** attempts },
    }
    full_export = FullGenericExport.find(id)
    domain_or_customer = full_export.exportable_services.first.domain || full_export.exportable_services.first.customer
    csv_name = domain_or_customer.name.split(".").first
    File.open("/tmp/exports/#{csv_name}.csv", "w") do |f|
      f.puts %w(account_name service_type ended_at service_id export_result archive_url).to_csv
      export_count = 0
      failed_service_ids = []
      services = full_export.exportable_services.eager_load(:parent_service).order("lower(services.account_name) ASC, lower(parent_services_services.account_name), services.type ASC")
      services.find_each do |s|
        puts "#{s.id} ..."
        if [:successful, :partial_failed].include?(full_export.get_status(s, false))
          s.change_datastore do
            export_run = nil
            begin
              Retriable.retriable(retry_opts) do
                export_run = s.export_runs.find { |run| run.full_domain_export_id == full_export.id }
              end
            rescue => e
              failed_service_ids << s.id
            end
            if export_run.present?
              f.puts [s.account_name, s.type, export_run.ended_at.to_date, s.id, export_run.state, export_run.archive_url].to_csv
              export_count += 1
            end
          end
        end
      end
      if export_count == 0
        f.puts "No successful exports were found.\n"
      end
      if failed_service_ids.any?
        puts "The following services returned errors, please check manually:"
        failed_service_ids.each do |id|
          puts id
        end
      end
    end
  end
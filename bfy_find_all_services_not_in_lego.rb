#Set the customer variable
c = Customer.find [CUSTOMER_ID]

#declare array to keep services not in lego
services = Array.new

#exchange/mail
exchange_services = c.services.where(:type => "Office365MailService").ids

#onedrive
onedrive_services = c.services.where(:type => "Office365OneDriveService").ids

#sharepoint
sharepoint_services = c.services.where(:type => "Office365SharePointService").ids

#googlemail
googlemail_services = c.services.where(:type => "GoogleMailService").ids

#googledrive
googledrive_services = c.services.where(:type => "GoogleDocsService").ids

#googlecalendar
googlecalendar_services = c.services.where(:type => "GoogleCalendarService").ids

#googlecontacts
googlecontacts_services = c.services.where(:type => "GoogleContactsService").ids


exchange_services.each do |id|
    service = Service.find id
    if service.lego_backups_only? == false
        services.push(service)
    end
end

onedrive_services.each do |id|
    service = Service.find id
    if service.lego_backups_only? == false
        services.push(service)
    end
end

sharepoint_services.each do |id|
    service = Service.find id
    if service.lego_backups_only? == false
        services.push(service)
    end
end

googlemail_services.each do |id|
    service = Service.find id
    if service.lego_backups_only? == false
        services.push(service)
    end
end

googledrive_services.each do |id|
    service = Service.find id
    if service.lego_backups_only? == false
        services.push(service)
    end
end

googlecalendar_services.each do |id|
    service = Service.find id
    if service.lego_backups_only? == false
        services.push(service)
    end
end

googlecontacts_services.each do |id|
    service = Service.find id
    if service.lego_backups_only? == false
        services.push(service)
    end
end

#Create and grab a collection of emails you want to grab service ids for
email_array = [ARRAY_OF_EMAILS_PROVIDED]

#Set the customer id
c = Customer.find [CUSTOMER_ID]

#Declare necessary arrays
services = Array.new
parent_id_array = Array.new

#grab service ids for parent services
email_array.each do |emails|
    user = User.find_by_email emails
    parent_service = user.services
    parent_service_id = parent_service.ids.join
    parent_id_array.push(parent_service_id)
    services.push(parent_service_id)
end

#grab service ids for Google Drive services
parent_id_array.each do |id|
    service = c.services.where(:type => "GoogleDocsService", :parent_service_id => id)
    service_id = service.ids.join
    services.push(service_id)
end

#grab service ids for GMail services
parent_id_array.each do |id|
    service = c.services.where(:type => "GoogleMailService", :parent_service_id => id)
    service_id = service.ids.join
    services.push(service_id)
end

#grab service ids for Calendar Services
parent_id_array.each do |id|
    service = c.services.where(:type => "GoogleCalendarService", :parent_service_id => id)
    service_id = service.ids.join
    services.push(service_id)
end

#grab service ids for Contacts services
parent_id_array.each do |id|
    service = c.services.where(:type => "GoogleContactsService", :parent_service_id => id)
    service_id = service.ids.join
    services.push(service_id)
end


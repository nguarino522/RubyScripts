#Create and grab a collection of emails you want to grab service ids for
email_array = [ARRAY_OF_EMAILS_PROVIDED]

#Set the customer id
c = Customer.find <id>

#Declare service id array i.e. input
input = Array.new


#Pull each parent service ID for each email and
#pull each service for gdrive and gmail from parent service ID and send to input array
email_array.each do |emails|
    user = User.find_by_email emails
    parent_service = user.services
    parent_service_id = parent_service.ids
    service = c.services.where(:type => "GoogleDocsService", :parent_service_id => parent_service_id)
    input.push(service)
    service = c.services.where(:type => "GoogleMailService", :parent_service_id => parent_service_id)
    input.push(service)
end


#Create and grab a collection of emails you want to grab service ids for
email_array = [ARRAY_OF_EMAILS_PROVIDED]

#Declare parent id array
parent_id_array = Array.new

#Set the customer id
c = Customer.find <id>

#Declare service id array i.e. input
input = Array.new

#Pull each parent service ID for each email and add to parent id array
for i in [email_array] do
    user = User.find_by_email i
    parent_service = user.services
    parent_service_id = parent_service.ids
    parent_id_array.push(parent_service_id)
end

#Pull each service for gdrive and gmail and send to input array
for i in [parent_id_array] do
    service = c.services.where(:type => "GoogleDocsService", :parent_service_id => parent_service_id)
    service_id = service.ids
    input.push(service_id)
    service = c.services.where(:type => "GoogleMailService", :parent_service_id => parent_service_id)
    service_id = service.ids
    input.push(service_id)
end



#Create and grab a collection of emails you want to grab service ids for
email_array = [ARRAY_OF_EMAILS_PROVIDED]

#Set the customer id
c = Customer.find [CUSTOMER_ID]

#Declare necessary arrays, final input array and array of parent ids
input = Array.new
parent_id_array = Array.new

#Pull each parent service ID and output to parent service id array
email_array.each do |emails|
    user = User.find_by_email emails
    parent_service = user.services
    parent_service_id = parent_service.ids.join
    parent_id_array.push(parent_service_id)
end

#populate input array with gmail service ids
parent_id_array.each do |id|
    service = c.services.where(:type => "GoogleDocsService", :parent_service_id => id, :hidden => false)
    service_id = service.ids.join
    input.push(service_id)
end

#populate input array with gdocs service ids
parent_id_array.each do |id|
    service = c.services.where(:type => "GoogleMailService", :parent_service_id => id, :hidden => false)
    service_id = service.ids.join
    input.push(service_id)
end
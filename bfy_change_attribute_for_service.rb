
# takes in an array of service ids called services

#example sets all services in array 'hidden' attribute to false
services.each do |id|
    s = Service.find id
    s.hidden=false
    s.save!
end
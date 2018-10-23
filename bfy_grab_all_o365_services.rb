
email_array = [ARRAY_OF_EMAILS_PROVIDED]

c = Customer.find [CUSTOMER_ID]

input = Array.new
services = Array.new

email_array.each do |emails|
    seat = Seat.find_by_principal_name emails
    services.push(seat.services)
end


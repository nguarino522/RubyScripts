def enable_shared_mailboxes

    puts "Please enter customer ID you wish to re-enable all disabled Shared Mailbox services on: "
    customer_id = gets.to_i

    c = Customer.find customer_id

    shared_seats = c.office365_seats.where(:is_shared_resource => true)

    services = Array.new

    shared_seats.each do |seat|
        servs = seat.services
        servs.each do |s|
            if s.disabled_code == 5
                services << s
            end
        end
    end

    services.each do |s|
        s.disabled_code = 0
        s.enable
        s.save!
    end

    puts "All Shared Mailbox services that were archived have now been re-enabled."

end
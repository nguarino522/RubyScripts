
class EnableSharedMailboxes
    
    def perform
        grab_customer_id
        grab_all_shared_mailboxes
        grab_services_with_disabled_code_5
        enable_services
        puts "All Shared Mailbox services that were archived have now been re-enabled."
    end

    def grab_customer_id
        puts "Please enter customer ID you wish to re-enable all disabled Shared Mailboxes on: "
        customer_id = gets.chomp
        c = customer.find customer_id
    end

    def grab_all_shared_mailboxes
        shared_seats = c.office365_seats.where(:is_shared_resource => true)
    end

    def grab_services_with_disabled_code_5
        services = Array.new
        shared_seats.each do |seat|
            servs = seat.services
            servs.each do |s|
                services << s
            end
        end
    end

    def enable_services
        services.each do |s|
            s.disabled_code = 0
            s.enable
            s.save!
        end
    end

end


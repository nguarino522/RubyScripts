#assumes array of emails called emails

#declared array members
members = Array.new


emails.each do |m|
    member = Member.find_by_principal_name m
    if member == nil
        puts "Unable to find the member #{m}..."
    else
        puts "Attempting to delete #{m} member..."
        member.destroy!
    end  
end ; 0  

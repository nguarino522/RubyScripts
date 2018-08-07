
#declare arrays and populate somehow, can do @seat_emails = %w() to manually do so, other array will be populated in loop below
@seat_emails = Array.new
@member_ids = Array.new

#go through emails array and populate member ids array
@seat_emails.each do |i|
    s = Seat.find_by_principal_name i
    member_id = s.member_id
    @member_ids << member_id.to_s
end

#add one drive service to each seat/member
member_ids.each do |m|
	services_creator = Office365::ServicesCreator.new(m.seat)
	service_type = "Office365OneDriveService"
	services_creator.create_user_service_of_class(service_type.constantize)
	m.seat.services
end
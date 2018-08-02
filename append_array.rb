#array of 'addlist' for example 

addlist.each do |i|
    i = i.gsub!("https://forrester.sharepoint.com", "")
end

loop do
  ip = IPSocket.getaddress("parkourutah.com")

  if ip == "45.55.180.23"
    print "\e[31m.\e[0m"
  else
    print "\a\e[33m.\e[0m"
  end

  sleep 60
end

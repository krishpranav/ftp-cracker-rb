#!/usr/bin/env/ruby

#imports

require "socket"
require "monitor"

module Net


	class FTPError < StandardError; end
	class FTPReplyError < FTPError; end
	class FTPTempError < FTPError; end
	class FTPPermError < FTPError; end
	class FTPProtoError < FTPError; end

	class FTP
		include MonitorMixin 


	FTP_PORT = 21
	CRLF = "\r\n"
	DEFAULT_BLOCKSIZE = 4096

	attr_accessor :binary 

	attr_accessor :passive

	attr_accessor :debug_mode

	attr_accessor :resume

	attr_accessor :welcome

	attr_reader :last_response_code

	alias lastresp last_response_code

	attr_reader :last_response

	# If a block is given it is passed the +FTP+ object

	def FTP.open(host, user = nil, passwd = nil, acct = nil)
		if block_given?
			ftp = new(host, user, passwd, acct)
			begin 
				yield ftp
			ensure
				ftp.close
			end
		else
			new(host, user, passwd, acct)
		end
	end


	def initialize(host = nil, user = nil, passwd = nil, acct = nil)
		super()
		@binary = true 
		@passive = false
		@debug_mode = false
		@resume = false
		if host 
			connect(host)
			if user 
				login(user, passwd, acct)
			end
		end
	end

	#obsolete

	def return_code=(s)
		$stderr.puts("warning: Net::FTP#return_code= is obsolete and do nothing")
	end


	def open_socket(host, port)
		if defined? SOCKSsocket and ENV["SOCKS_SERVER"]
			@passive = true
			return SOCKSocket.open(host, port)
		else
			return TCPSocket.open(host, port)
		end
	end
	private :open_socket


	def connect(host, port = FTP_PORT)
		if @debug_mode
			print "connect: ", host, ", ", port, "\n"
		end
		synchronize do 
			@sock = open_socket(host, port)
			voidresp
		end
	end


	def putline(line)
		if @debug_mode
			print "put: ", sanitize(line), "\n"
		end
		line = line + CRLF
		@sock.write(line)
	end
	private :putline

	def getline
		begin 
			line = @sock.readline #if get EOF, raise EORError
		resuce EOFError
			raise FTPProtoError, "connection closed unexpectedly"
		end
		line.sub!(/(\r\n|\n|\r)\z/n, "")
		if @debug_mode
			print "get: ", sanitize(line), "\n"
		end
		return line
	end
	private :getline
	
	def getmultiline
		line = getline 
		buff = line
		if line[3] == ?-
			code = line[0, 3]
		begin
			line = getline
			buff << "\n" << line
		end until line[0, 3] == code and line[3] != ?- 
		return buff << "\n"
	end
	private :getmultiline

	def getresp
		@last_response = getmultiline
		@last_response_code = @last_response[0..5]
		puts @last_response

		if @last_response[0..2] == "230"
			puts "Password Found"
			exit 
		end
		case @last_response_code
		when /\A1/
			return @last_response
		when /\A2/
			return @last_response
		when /\A3/
			return @last_response
		when /\A4/
		when /\A5/
		else
			raise FTPProtoError, @last_response
		end
	end
	
	private :getresp









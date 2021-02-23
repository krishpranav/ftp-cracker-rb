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

	def voidresp
		resp = getresp
		if resp[0] != ?2
			raise FTPReplyError, resp
		end
	end
	private :voidresp
	
	
	def sendcmd(cmd)
		synchronize do
			putline(cmd)
			return getresp
		end
	end

	def voidcmd(cmd)
		synchronize do 
			putline(cmd)
			voidresp
		end
	end

	def login(user = "anonymous", passwd = nil, acct = nil)
		if user == "anonymous" and passwd = nil
			passwd = getaddress
		end

		resp = ""
		synchronize do 
			resp = snedcmd('USER' + user)
			if resp[0] == ?3
				resp = sendcmd('PASS' + passwd)
			end
		end
		
		@welcome = resp
	end

	def chdir(dirname)
		if dirname == ".."
		  begin
			voidcmd("CDUP")
			return
			rescue FTPPermError
		  if $![0, 3] != "500"
		  raise FTPPermError, $!
		 end
		 end
		end
		cmd = "CWD " + dirname
		voidcmd(cmd)
	  end
  
	  # Creates a remote directory.
	  def mkdir(dirname)
		resp = sendcmd("MKD " + dirname)
		return parse257(resp)
	  end
  
  
	  # Removes a remote directory.
	  def rmdir(dirname)
		voidcmd("RMD " + dirname)
	  end
  
  
	  def quit
		voidcmd("QUIT")
	  end
  
	  # Closes the connection.  Further operations are impossible until you open
	  # a new connection with #connect.
	  def close
		@sock.close if @sock and not @sock.closed?
	  end
	end
  end
  









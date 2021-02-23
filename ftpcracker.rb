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





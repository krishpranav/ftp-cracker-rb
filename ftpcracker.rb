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
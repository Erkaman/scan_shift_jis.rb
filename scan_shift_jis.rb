#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'

##
## First, we parse command line arguments.  
##

options = OpenStruct.new
options.minimum_length = 3

opt_parser = OptionParser.new do |opts|
	opts.banner = "Usage: #{__FILE__} [options] INPUT_FILE"

	opts.separator ""
	opts.separator "Summary"
	opts.separator "    Scan a file for Japanese strings encoded with Shift-JIS"
	
	opts.separator ""	
	opts.separator "Options"

	opts.on("-n N", Integer, "Print only strings with a minimum length of N characters. Defaults to #{options.minimum_length}") do |n|
		options.minimum_length = n
	end

	opts.on_tail("-h", "--help", "Show this message") do
		puts opts
		abort
    end
end
opt_parser.parse!(ARGV)

if options.minimum_length < 0 then
	STDERR.puts "ERROR: The minimum length must be positive!"
	abort
end

file_name = ARGV[0]

if not file_name then
	STDERR.puts "ERROR: You must specify an input file!"
	abort
end

if not File.exists?(file_name) then
	STDERR.puts "ERROR: The input file does not exist!"
	abort
end

##
## Next, we scan the input file for strings. 
##

# Uses a buffer to implement quick file reading. 
class BufferedFile 

	BUFFER_SIZE = 4096

	def initialize(file) 
		@file = file
		@eof = false
		@buffer_index = 0
		@buffer = []
	end
	
	def read_byte()
		if @buffer.length == @buffer_index then
			refill_buffer()
		end
		
		byte = @buffer[@buffer_index].ord
		@buffer_index += 1
		
		byte
	end
	
	def eof?() 	
		@file.eof? and @buffer_index == @buffer.length
	end
	
	private def refill_buffer()
		@buffer = @file.read(BUFFER_SIZE)
		@buffer_index = 0
	end
end

# every Shift-JIS encoded Japanese character occupies two bytes. 
# This variable tells that we are scanning for the first byte. 
state = :scan_first 
 
jis_str = []

# contains the scanned strings and their corresponding addresses in the input file.
found_strs = []

file_pos = 0

# Every Shift-JIS encoded Japanese character occupies 2 bytes. 
MINIMUM_LENGTH = options.minimum_length * 2

File.open(file_name) do|file|
    bufferedFile = BufferedFile.new(file)
	until bufferedFile.eof?
		char = bufferedFile.read_byte()
		
		if (state == :scan_first &&
			 ((char >= 0x81 && char <= 0x84) || 
               (char >= 0x87 && char <= 0x9f) ||
			   (char >= 0xe0 && char <= 0xef)))  then # is valid first byte?
		
			jis_first = char
			state = :scan_second # start scanning for the second byte.
			
		elsif (state == :scan_second &&
			 ((char >= 0x40 && char <= 0x9e) || 
               (char >= 0x9f && char <= 0xfc)))  then # is valid second byte?
			   
			jis_second = char
			  
			# We now have a complete Japanese character! Append it:
			jis_str << jis_first
			jis_str << jis_second
			  
			# start scanning for another Japanese character.
			state = :scan_first
		else
			# we have reached the end of the string now.
			state = :scan_first
			if jis_str.length >= (MINIMUM_LENGTH) then	
				str_pos = file_pos - jis_str.length
				found_strs << [jis_str.pack('c*'), str_pos]
			end
			jis_str = [] # start a new string.
		end
		file_pos += 1
	end
	
	# handle the last string in the file. 
	if jis_str.length >= (MINIMUM_LENGTH) then	
		str_pos = file_pos - jis_str.length
		found_strs << [jis_str.pack('c*'), str_pos]
	end
end

##
## Finally, we print the scanned strings as a table
##

if found_strs.length > 0 then

	address_col = "address".ljust(20)
	puts "#{address_col}|string"
	found_strs.each do |str, address|
		
		puts "#{address.to_s(16).upcase.ljust(20)}|#{str}"
	end
else
	puts "No strings were found."
end
#!/usr/bin/env ruby

#
# Stack Plist Encrypter Version 0.1
# All credits to Isaiah
# Fork of https://github.com/yourhead/s3
#

STDERR.puts "**************************************************"
STDERR.puts "* Stack Plist Encrypter Version 0.1              *"
STDERR.puts "**************************************************"
STDERR.puts ""

require 'openssl'
require 'base64'

begin
    require 'plist'
rescue LoadError
    STDERR.puts "Plist library is required, install with following command:"
    STDERR.puts "sudo gem install plist -v 3.2.0"
    abort
end

# Should be just one argument -- a single stack package, optional with including child stacks inside the package
if (!ARGV[0])
    abort("usage: ruby encrypt_stack.rb [stack_package.stack]")
end

# Make sure it exists
filePath = ARGV[0]
if (!File.exist?(filePath))
    STDERR.puts "stack package does not exist"
    abort("usage: encrypt_stack [stack_package.stack]")
end

# Make sure it is a directory
if (!Dir.exist?(filePath))
    STDERR.puts "stack package is not a directory"
    abort("usage: encrypt_stack [stack_package.stack]")
end

# use the local public key
publicKey = OpenSSL::PKey::RSA.new (File.read ('./stack_public_key.pem'))
if (!publicKey)
    abort("Could not find stacks public key in file system")
end

# iterate over all Info.plist files recursively
Dir.glob("#{filePath}/**/Info.plist").each {
    |file| STDERR.puts "Processing " + file
	# File.delete(file) if File.file? file

    # Read the data file
    data = File.read (file)
    if (!data)
        STDERR.puts "Could not read data file " + file
    end

    doc = Nokogiri::XML(data)

    # STDERR.puts data.index("dict")

    # Generate a random password and hash it
    password = OpenSSL::Random.pseudo_bytes(64)
    md5 = OpenSSL::Digest::MD5.new
    symetricKey = md5.digest (password)
    if (!password)
        abort("Could create a symetric key")
    end

    # encrypt the data using a simple fast RC 4 cipher
    cipher = OpenSSL::Cipher.new('RC4')
    cipher.key = symetricKey
    dataEncrypted = cipher.update (data)
    if (!dataEncrypted)
        abort("Symetric encryption failed")
    end

    # use the stacks public key to encrypt the password
    passwordEncrypted = publicKey.public_encrypt (password)
    if (!passwordEncrypted)
        abort("Public-key encryption failed")
    end

    # write the results to standard out, using strict base64 (no newlines!)
    # puts (Base64.strict_encode64 (passwordEncrypted)) + (Base64.strict_encode64 (dataEncrypted))

}












#!/usr/bin/env ruby

require 'openssl'
require 'base64'

#
# Public key encryption can only encrypt small bits of data. So
# to do the same with large amounts of data we use regular symetric
# encryption with a random password. Then public key encrypt the password.
# https://en.wikipedia.org/wiki/Public-key_cryptography
#

# Should be just one argument -- a single stack package, optional with including child stacks inside the package
if (!ARGV[0])
	abort("usage: encrypt_stack [stack package]")
end

# Make sure it exists
filePath = ARGV[0]
if (!File.exist?(filePath))
	STDERR.puts "stack package does not exist"
	abort("usage: encrypt_stack [stack package]")
end

#if (!Dir.exist?(filePath))
#	STDERR.puts "stack package is not a directory"
#	abort("usage: encrypt_stack [stack package]")
#end

# Read the data file
data = File.read (filePath)
if (!data)
	STDERR.puts "Could not read data file"
	abort("usage: encrypt_stack [stack package]")
end

# use the local public key
publicKey = OpenSSL::PKey::RSA.new (File.read ('./stack_public_key.pem'))
if (!publicKey)
	abort("Could not find stacks public key in file system")
end

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
puts (Base64.strict_encode64 (passwordEncrypted)) + (Base64.strict_encode64 (dataEncrypted))

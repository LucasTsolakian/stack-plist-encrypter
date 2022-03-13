#!/usr/bin/env ruby

# Stack Plist Sorter Version 0.1
# Fork of https://github.com/yourhead/s3
# All credits to Isaiah

STDERR.puts "**************************************************"
STDERR.puts "* Stack Plist Sorter Version 0.1                 *"
STDERR.puts "**************************************************"
STDERR.puts ""

# require 'openssl'
# require 'base64'

begin
    require 'plist'
rescue LoadError
    STDERR.puts "Plist library is required, install with following command:"
    STDERR.puts "sudo gem install plist -v 3.2.0"
    abort
end

# Should be just one argument -- a single stack package, optional with including child stacks inside the package
if (!ARGV[0])
    abort("usage: ruby sort_stack.rb [stack_package.stack]")
end

# Make sure it exists
filePath = ARGV[0]
if (!File.exist?(filePath))
    STDERR.puts "stack package does not exist"
    abort("usage: sort_stack [stack_package.stack]")
end

# Make sure it is a directory
if (!Dir.exist?(filePath))
    STDERR.puts "stack package is not a directory"
    abort("usage: sort_stack [stack_package.stack]")
end

# use the local public key
# publicKey = OpenSSL::PKey::RSA.new (File.read ('./stack_public_key.pem'))
# if (!publicKey)
#     abort("Could not find stacks public key in file system")
# end

# iterate over all Info.plist files recursively
Dir.glob("#{filePath}/**/Info.plist").each {
    |file| 
    STDERR.puts "Process " + file

    # parse existing Info.plist file
    oldPlist = Plist.parse_xml(file)

    # create new empty plist for storing attributes to be encrypted
    # for now, search for attributes 'SUFeedURL', 'customItems' for encryption
    # newPlist = {}
    # attributes = ['SUFeedURL', 'customItems']
    # attributes.each {
    #     |attribute|
    #     if !!oldPlist[attribute]
    #         newPlist[attribute] = oldPlist[attribute]
    #         oldPlist.delete(attribute)
    #     end
    # }

    # only encrypt if new plist is filled with attributes
    # if !newPlist.empty?
        # Generate a random password and hash it
        # Generate for every plist new for higher security
        # password = OpenSSL::Random.pseudo_bytes(64)
        # md5 = OpenSSL::Digest::MD5.new
        # symetricKey = md5.digest (password)
        # if (!password)
        #     abort("Could create a symetric key")
        # end

        # encrypt the data using a simple fast RC 4 cipher
        # cipher = OpenSSL::Cipher.new('RC4')
        # cipher.key = symetricKey
        # dataEncrypted = cipher.update (newPlist.to_plist)
        # if (!dataEncrypted)
        #     abort("Symetric encryption failed")
        # end

        # use the stacks public key to encrypt the password
        # passwordEncrypted = publicKey.public_encrypt (password)
        # if (!passwordEncrypted)
        #     abort("Public-key encryption failed")
        # end

        # write the results to the old plist in attribute 'stackData', using strict base64 (no newlines!)
        # oldPlist['stackData'] = (Base64.strict_encode64 (passwordEncrypted)) + (Base64.strict_encode64 (dataEncrypted))

        # Write old plist to file
        File.write(file, oldPlist.to_plist)

        STDERR.puts "Sort    " + file
    # else
    #     STDERR.puts "Skipped " + file
    # end

}
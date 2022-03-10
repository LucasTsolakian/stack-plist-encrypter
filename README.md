# Stack Plist Encrypter

Script for mass encryption of plist data in stack packages.

## Requirements

- Ruby (already on your Mac)
- https://github.com/patsplat/plist extension (install via `sudo gem install plist -v 3.2.0`)

## Usage

**Caution: This script will change the data in the given stacks package. Only operate after created a backup, or inside a build script.**

1. The script will recursively encrypt all Info.plist files on the fly. No need to create a separate plist for your private info. By default, the attributes `SUFeedURL` and `customItems` will be encrypted. You are able to extend these attributes inside the script. The encrypted data will replace the values in your normal plist.
2. Encrypt the plist using the ruby script `ruby encrypt_stack.rb stack_package.stack`

## Encrypted P-List Data

Stacks 3.5 will check each stack plist for an encrypted data block.  This encrypted block will be decrypted and the data merged into the plist. This provides a way of hiding sensitive data from users and competitors.  You can, for instance, place the URL for your update server, and your Update Info into the encrypted data.

### Backward compatible and Opt In

Stacks without encrypted data will continue to work as always. Developers can choose if and when to utilize this feature.

### Goals

The goal is to provide a lightweight mechanism to protect sensitive data. The simple RC4 cipher is not military grade and should not be used to store passwords, personal or financial information.

### How it works

The developer uses the Stacks public key to encrypt a plist file. The encrypted data is added to the stack. When Stacks 3 loads the stack into the Stacks Library it will decrypt the information and incorporate it into the stack.

### Important details

 - The encryption used here is RC4. It's a streaming cipher that's very fast. How secure is it? It was what SSL was using a few years back -- so it's not bad -- but given enough CPU power there are several known ways to compromise it. The NSA is rumored to
 be able to decrypt RC4 streams in real time with specialized hardware. I chose this cipher because it is well understood and because it was used with SSL (web security and such) the implementations on each platform are very easy to make compatible. e.g.: we can encrypt things using macOS version of Ruby or even on a Php backend server and Stacks can decrypt them using OpenSSL.
 - Please use the public key that is provided in this github repository. Note: This key may change in the future.
 - There is a different public key inside the Stacks 3 bundle. It is a different type and will not validate stack updates.
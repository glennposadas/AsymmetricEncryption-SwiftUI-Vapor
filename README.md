# AsymmetricEncrytion-SwiftUI-Vapor
A research (sample applications) that uses SwiftUI + CryptoKit + Swift Server Side Vapor.

UPDATE 4/24:
I think I will have to postpone the Swift Vapor implementation as I deemed it unnecessary.
In this demo project, we are using SwiftyRSA and SwiftKeychainWrapper libraries. It demos the following:

1. Generation of RSA key pairs (private and public)
2. Storing the private key to the Keychain with synching to the iCloud automatically.
3. Encryption of a plain text/string.
4. Decryption of the base64 string from the server (assuming).
5. Signing (making a signature) the decrypted object.
6. Using signature to verify the decrypted object from the server.
7. Then finally, printing the plain text after verifying the signature.

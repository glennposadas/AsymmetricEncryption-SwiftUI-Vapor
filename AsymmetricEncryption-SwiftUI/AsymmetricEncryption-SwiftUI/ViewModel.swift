//
//  ViewModel.swift
//  AsymmetricEncryption-SwiftUI
//
//  Created by Glenn Posadas on 4/24/22.
//

import Foundation
import SwiftKeychainWrapper
import SwiftyRSA

let keychainPublicKeyKey = "com.glennposadas.AsymmetricEncryption-SwiftUI.publickey1"
let keychainPrivateKeyKey = "com.glennposadas.AsymmetricEncryption-SwiftUI.privateKey1"

class ViewModel: ObservableObject {
  
  @Published var showErrorMessage = false
  @Published var error: Error?
  
  func startEncryptThenDecrypt() {
    do {
      // ============================ 🔐 ENCRYPTION ============================ //
      
      // Make a `ClearMessage` using a plain text.
      let clear = try ClearMessage(string: "78", using: .utf8)
      
      // Prepare encryption of the data.
      // PLEASE NOTE:
      // Encryption - uses PUBLIC key
      // Decryption - uses PRIVATE key
      let storedPublicKey = try PublicKey(data: publicKey())
      
      // Now we have an `EncryptedMessage` object. Encrypted using public key
      let encrypted = try clear.encrypted(with: storedPublicKey, padding: .PKCS1)
      
      // ============================ 🔓 DECRYPTION ============================ //
      
      // Assuming the server passes base64 string to us, and we need to decrypt the data.
      let base64FromServer = encrypted.base64String
      
      // Then make an encrypted message object.
      let encryptedMessageFromServer = try EncryptedMessage(base64Encoded: base64FromServer)
      
      // Get the private key from the keychain (local or iCloud).
      let privateKey = try PrivateKey(data: privateKey())
      
      // Decrypt now the clear message from the server using the private key.
      let decryptedClearMessage = try encryptedMessageFromServer.decrypted(with: privateKey, padding: .PKCS1)
      
      // Tada! We now have a data object.
      let data = decryptedClearMessage.data
      
      // ============================ SIGNATURE AND PRINTING OF PLAIN TEXT ============================ //
      
      let signature = try decryptedClearMessage.signed(with: privateKey, digestType: .sha1)
      
      let isSuccessful = try decryptedClearMessage.verify(with: storedPublicKey, signature: signature, digestType: .sha1)
      
      print("isSuccessful: \(isSuccessful)")
      print("PLAIN TEXT--------> \(data.JSONResponseString)")
      
    } catch {
      self.error = error
    }
  }
  
  // ================= KEYS GENERATION, STORAGE, and EXTRACTION ================= //
  
  /// Returns a new pair of private and public keys. Generates only ONCE.
  func newKeyPair() throws -> (privateKeyData: Data, publicKeyData: Data) {
    let pair = try SwiftyRSA.generateRSAKeyPair(sizeInBits: 2048)
    
    let privateKeyData = try pair.privateKey.data()
    let publicKeyData = try pair.publicKey.data()
    
    KEYCHAIN.set(privateKeyData,
                 forKey: keychainPrivateKeyKey,
                 isSynchronizable: true)
    
    KEYCHAIN.set(publicKeyData,
                 forKey: keychainPublicKeyKey,
                 isSynchronizable: true)
    
    return (privateKeyData, publicKeyData)
  }
  
  func publicKey() throws -> Data {
    if let stored = KEYCHAIN.data(forKey: keychainPublicKeyKey, isSynchronizable: true) {
      return stored
    } else {
      return try newKeyPair().publicKeyData
    }
  }
  
  func privateKey() throws -> Data {
    if let stored = KEYCHAIN.data(forKey: keychainPrivateKeyKey, isSynchronizable: true) {
      return stored
    } else {
      return try newKeyPair().privateKeyData
    }
  }
  
  func clearError() {
    error = nil
    showErrorMessage = false
  }
}

extension Data {
  var JSONResponseString: String {
    do {
      let dataAsJSON = try JSONSerialization.jsonObject(with: self)
      let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
      return String(data: prettyData, encoding: .utf8) ?? String(data: self, encoding: .utf8) ?? ""
    } catch {
      return String(data: self, encoding: .utf8) ?? ""
    }
  }
}

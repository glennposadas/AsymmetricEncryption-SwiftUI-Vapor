//
//  ContentView.swift
//  AsymmetricEncryption-SwiftUI
//
//  Created by Glenn Posadas on 4/8/22.
//

import SwiftKeychainWrapper
import SwiftyRSA
import SwiftUI

let KEYCHAIN = KeychainWrapper(serviceName: Bundle.main.bundleIdentifier! + ".RSA", accessGroup: "publicKey")

struct ContentView: View {
  
  @ObservedObject var vm = VM()
  
  var body: some View {
    Text("Hello, world!")
      .padding()
      .onTapGesture {
        vm.testAE()
      }
      .alert(isPresented: $vm.showErrorMessage) {
        Alert(
          title: Text("Error"),
          message: Text(vm.error?.localizedDescription ?? ""),
          dismissButton: .default(Text("OK"), action: vm.clearError)
        )
      }
  }
}

let keychainPubliKeyKey = "com.glennposadas.AsymmetricEncryption-SwiftUI.publickey"
let keychainPrivateKeyKey = "com.glennposadas.AsymmetricEncryption-SwiftUI.privateKey"

class VM: ObservableObject {
  
  @Published var showErrorMessage = false
  @Published var error: Error?
  
  
  func newKeyPair() throws -> (privateKey: PrivateKey, publicKey: PublicKey) {
    try SwiftyRSA.generateRSAKeyPair(sizeInBits: 2048)
  }
  
  func publicKey() throws -> Data {
    if let stored = KEYCHAIN.data(forKey: keychainPubliKeyKey, isSynchronizable: true) {
      return stored
    } else {
      let publicKeyData = try newKeyPair().publicKey.data()
      
      KEYCHAIN.set(publicKeyData,
                   forKey: keychainPubliKeyKey,
                   isSynchronizable: true)
      
      return data
    }
  }
  
  func privateKey() throws -> Data {
    if let stored = KEYCHAIN.data(forKey: keychainPrivateKeyKey, isSynchronizable: true) {
      
      return stored
      
    } else {
      
      // Generate keys
      let keyPair = try SwiftyRSA.generateRSAKeyPair(sizeInBits: 2048)
      
      let privateKey = keyPair.privateKey
      let privatePem = try privateKey.pemString()
      
      let publicKey = keyPair.publicKey
      let data = try publicKey.data()
//      let publicPem = try publicKey.pemString()
      
      KEYCHAIN.set(data,
                   forKey: keychainPrivateKeyKey,
                   isSynchronizable: true)
      
      return data
    }
  }
  
  func testAE() {
    do {
      
      let storedPublicKey = try PublicKey(data: publicKey())
      let clear = try ClearMessage(string: "Clear Text", using: .utf8)
      
      let encrypted = try clear.encrypted(with: storedPublicKey, padding: .PKCS1)
      
      let data = encrypted.data
      let base64String = encrypted.base64String
      
      let privateKey = try PrivateKey(pemNamed: "private")
      let encrypted2 = try EncryptedMessage(base64Encoded: "AAA===")
      let clear2 = try encrypted.decrypted(with: privateKey, padding: .PKCS1)
      
      // Then you can use:
      let data2 = clear2.data
      let base64String2 = clear2.base64String
      let string = try clear2.string(encoding: .utf8)
      
      
      
      
      
    } catch {
      self.error = error
      showErrorMessage = true
    }
  }
  
  func clearError() {
    error = nil
    showErrorMessage = false
  }
}


//enum SampleEncryptionCustomError: LocalizedError {
//  case randomErr
//
//  var errorDescription: String? {
//    switch self {
//    case .randomErr:
//      return "Failed to encrypt your data"
//    }
//  }
//
//  var failureReason: String? {
//    switch self {
//    case .randomErr:
//      return "Something happened"
//    }
//  }
//
//  var recoverySuggestion: String? {
//    switch self {
//    case .randomErr:
//      return "Try again later"
//    }
//  }
//}

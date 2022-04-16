//
//  ContentView.swift
//  AsymmetricEncryption-SwiftUI
//
//  Created by Glenn Posadas on 4/8/22.
//

import SwiftyRSA
import SwiftUI

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

class VM: ObservableObject {
  
  @Published var showErrorMessage = false
  @Published var error: Error?
  
  func testAE() {
    do {
      let publicKey = try PublicKey(pemNamed: "public")
      let clear = try ClearMessage(string: "Clear Text", using: .utf8)
      let encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1)
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

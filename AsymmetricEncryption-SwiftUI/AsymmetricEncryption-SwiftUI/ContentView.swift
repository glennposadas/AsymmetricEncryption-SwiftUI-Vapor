//
//  ContentView.swift
//  AsymmetricEncryption-SwiftUI
//
//  Created by Glenn Posadas on 4/8/22.
//

import SwiftKeychainWrapper
import SwiftUI

let KEYCHAIN = KeychainWrapper.standard

struct ContentView: View {
  
  @ObservedObject var viewModel = ViewModel()
  
  var body: some View {
    Text("Hello, world!")
      .padding()
      .onTapGesture {
        viewModel.startEncryptThenDecrypt()
      }
  }
}

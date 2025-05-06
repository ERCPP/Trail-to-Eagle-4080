//
//  SettingsView.swift
//  Trail to Eagle
//
//  Created by Eric Wagner-Roberts on 3/6/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var objectCache: ObjectCache
    @State var isLoggedIn = KeychainManager.areTokensPresent()
    @State var versionText = "App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-") | Server Version: -"
    @State private var apiSignedInText = "Trail to Eagle Account"
    @State private var showingSBSignInSheet = false
    @State private var showingTTESignInSheet = false
    @State private var hasLoaded = false

    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // **Trail to Eagle Account Section**
                VStack {
                    Text(apiSignedInText)
                        .font(.headline)
                    
                    Button(action: {
                        showingTTESignInSheet.toggle()
                    }) {
                        Text("Sign In")
                            .foregroundColor(.blue)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    }
                }
                
                // **Available Units Section**
                VStack {
                    Text("Available Units")
                        .font(.headline)
                    
                    List(objectCache.units) { unit in
                        Text("\(unit.name)")
                            .listRowBackground(Color("ListBackgroundColor"))
                    }
                    .scrollContentBackground(.hidden)
                    .frame(maxHeight: 200) // Restricts list height to avoid excessive scrolling
                }
                
                // **Logout Button**
                Button(action: {
                    objectCache.apiManager.removeTokens()
                }) {
                    Text("Log Out")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .disabled(!isLoggedIn)
                .opacity(isLoggedIn ? 1.0 : 0.5)
                
                // **Version & Copyright Information**
                VStack(spacing: 5) {
                    Text(versionText)
                        .font(.footnote)
                        .padding(.top)
                    
                    Text("Copyright © " + String(Calendar(identifier: .gregorian).dateComponents([.year], from: Date()).year ?? 0) + " Eric Wagner-Roberts.")
                        .font(.footnote)
                }
            }
            .padding()
            .onReceive(objectCache.apiManager.tokensDidChange) { _ in
                isLoggedIn = KeychainManager.areTokensPresent()
            }
            .onAppear {
                if !hasLoaded {
                    objectCache.refreshUnits()
                    objectCache.apiManager.version { result in
                        versionText = "App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-") | Server Version: \(result)"
                    }
                    objectCache.apiManager.authTest { result in
                        apiSignedInText = "Trail to Eagle Account: \(result)"
                    }
                    hasLoaded = true
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showingTTESignInSheet) {
            TTELoginView(apiManager: objectCache.apiManager)
        }
    }
}

// **Preview**
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(objectCache: ObjectCache())
    }
}

//
//  ScoutbookLoginView.swift
//  Trail to Eagle
//
//  Created by Eric Wagner-Roberts on 3/8/25.
//

import SwiftUI
import WebKit

struct ScoutbookLoginView: View {
    @Environment(\.dismiss) var dismiss // Allows dismissing the sheet
    @State private var cookies: [HTTPCookie] = []
    @State private var timer: Timer? // Timer for polling cookies

    var body: some View {
        VStack {
            Text("Logging in...")
                .font(.title)
                .padding()

            ScoutbookLoginManager(url: URL(string: "https://scoutbook.scouting.org/")!, cookies: $cookies)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            startCookieMonitoring() // Start checking for cookies when view appears
        }
        .onDisappear {
            stopCookieMonitoring() // Clean up the timer when view disappears
        }
    }

    /// Starts a timer to check for cookies every 2 seconds
    func startCookieMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            getCookiesFromDataStore()
        }
    }

    /// Stops the cookie monitoring timer
    func stopCookieMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    /// Retrieves cookies from WKWebsiteDataStore and checks for "SessionToken"
    func getCookiesFromDataStore() {
        let webView = WKWebView()
        let dataStore = webView.configuration.websiteDataStore

        dataStore.httpCookieStore.getAllCookies { cookies in
            DispatchQueue.main.async {
                self.cookies = cookies
                var cookieDictionary: [String: String] = [:]

                for cookie in cookies {
                    print("Cookie: \(cookie.name) = \(cookie.value)")

                    // Add each cookie to the dictionary
                    cookieDictionary[cookie.name] = cookie.value

                    // Check for "SessionToken" cookie
                    if cookie.name == "SessionToken" {
                        print("SessionToken found! Closing view.")
                        stopCookieMonitoring() // Stop polling for cookies
                        dismiss() // Close the view
                    }
                }
                
                // Convert the dictionary to JSON format
                if let jsonData = try? JSONSerialization.data(withJSONObject: cookieDictionary, options: .prettyPrinted) {
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        print("Cookies in JSON format: \(jsonString)")
                    }
                }
            }
        }
    }
}

//
//  ScoutbookLoginManager.swift
//  Trail to Eagle
//
//  Created by Eric Wagner-Roberts on 3/8/25.
//

import SwiftUI
import WebKit

struct ScoutbookLoginManager: UIViewRepresentable {
    let url: URL
    @Binding var cookies: [HTTPCookie] // Pass cookies via binding

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.3 Safari/605.1.15"

        // Observe cookies
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            context.coordinator.didReceiveCookies(cookies)
        }

        let request = URLRequest(url: url)
        webView.load(request)

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: ScoutbookLoginManager

        init(parent: ScoutbookLoginManager) {
            self.parent = parent
        }

        func didReceiveCookies(_ cookies: [HTTPCookie]) {
            DispatchQueue.main.async {
                self.parent.cookies = cookies // Update cookies
            }
        }
    }
}

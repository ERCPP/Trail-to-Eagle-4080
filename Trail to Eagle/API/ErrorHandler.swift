//
//  ErrorHandler.swift
//  Trail to Eagle
//
//  Created by Eric Wagner-Roberts on 12/22/23.
//

import Foundation
import UIKit

enum APIError: Error {
    // From API
    case requestFailed
    case unauthorized
    case badRequest
    //Related to API
    case decodeFailed
    case serializationFailed
    case tokenSaveFailed
}

class ErrorHandler {
    // Function to handle APIManager Errors.
    static func apiError(errorIn: APIError, location: String) {
        switch errorIn {
            case .requestFailed:
                ErrorHandler.showErrorMessage(for: errorIn, title: "Unknown API Error", message: "An error occured at \(location)")
            case .unauthorized:
                if (location == "refresh") {
                    ErrorHandler.showErrorMessage(title: "Session Ended", message: "Your session has expired and you must login again.")
                } else if (location == "login") {
                    ErrorHandler.showErrorMessage(title: "Invalid Credentials", message: "Username or Password was incorrect. Please try again.")
                } else {
                    // Print to console for debugging since wouldnt show an alert.
                    print("API Error - \(location): unauthorized")
                }
            case .badRequest:
                ErrorHandler.showErrorMessage(for: errorIn, title: "Bad Request", message: "Server responded that our request was bad at \(location)")
            case .decodeFailed:
                ErrorHandler.showErrorMessage(for: errorIn, title: "Failed to Decode Response", message: "An error occured decoding the API response at \(location)")
            case .serializationFailed:
                ErrorHandler.showErrorMessage(for: errorIn, title: "Failed to Create Request", message: "An error occured serializing the API request at \(location)")
            case .tokenSaveFailed:
                ErrorHandler.showErrorMessage(for: errorIn, title: "Failed to Save Token", message: "An error occured saving the access token at \(location)")
        }
    }
    
    // Function to display an alert without including the error.
    static func showErrorMessage(title: String, message: String) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let topViewController = windowScene.windows.first?.rootViewController {
                    let alertController = UIAlertController(
                        title: title,
                        message: message,
                        preferredStyle: .alert
                    )
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    topViewController.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    // Function to display an alert when an error occurs with an erorr datatype.
    static func showErrorMessage(for status: Error, title: String, message: String) {
        var errorMessage = message
        errorMessage += ": \(status.localizedDescription)"
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let topViewController = windowScene.windows.first?.rootViewController {
                    let alertController = UIAlertController(
                        title: title,
                        message: message,
                        preferredStyle: .alert
                    )
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    topViewController.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    // Function to display an alert when an error occurs with an OSStatus.
    static func showErrorMessage(for status: OSStatus, title: String, message: String) {
        guard status != noErr else { return }

        var errorMessage = message
        if #available(iOS 11.3, *) {
            errorMessage += ": \(SecCopyErrorMessageString(status, nil)!)"
        }

        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let topViewController = windowScene.windows.first?.rootViewController {
                    let alertController = UIAlertController(
                        title: title,
                        message: errorMessage,
                        preferredStyle: .alert
                    )
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    topViewController.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}

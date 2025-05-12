//
//  LocalDataHandler.swift
//  Trail to Eagle
//
//  Created by Eric Wagner-Roberts on 3/9/25.
//

import Foundation
import Security
import UIKit
import UserNotifications

class KeychainManager {
    static let accessTokenKey = "global.juno.trail-to-eagle.accessToken"
    static let refreshTokenKey = "global.juno.trail-to-eagle.refreshToken"
    
    // Store access and refresh tokens in Keychain
    static func storeTokensInKeychain(accessToken: String, refreshToken: String) {
        KeychainManager.updateValueInKeychain(key: KeychainManager.accessTokenKey, value: accessToken)
        KeychainManager.updateValueInKeychain(key: KeychainManager.refreshTokenKey, value: refreshToken)
    }
    
    // Retrieve access token from Keychain
    static func retrieveAccessToken() -> String? {
        return retrieveStringFromKeychain(key: accessTokenKey)
    }
    
    // Retrieve refresh token from Keychain
    static func retrieveRefreshToken() -> String? {
        return retrieveStringFromKeychain(key: refreshTokenKey)
    }
    
    // Remove both access and refresh tokens from Keychain
    static func removeTokens() {
        KeychainManager.deleteValueFromKeychain(key: KeychainManager.accessTokenKey)
        KeychainManager.deleteValueFromKeychain(key: KeychainManager.refreshTokenKey)
    }
    
    // Retrieve string value associated with a key from Keychain
    static func retrieveStringFromKeychain(key: String) -> String? {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as CFDictionary
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        } else {
            return nil
        }
    }
    
    // Update access token in Keychain
    static func updateAccessTokenInKeychain(newAccessToken: String) {
        updateValueInKeychain(key: accessTokenKey, value: newAccessToken)
    }
    
    // Update value in Keychain
    static func updateValueInKeychain(key: String, value: String) {
        if let data = value.data(using: .utf8) {
            let query = [
                kSecClass as String: kSecClassGenericPassword as String,
                kSecAttrAccount as String: key
            ] as CFDictionary
            
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            
            var status = SecItemUpdate(query, attributes as CFDictionary)
            
            if status == errSecItemNotFound {
                let newQuery = [
                    kSecClass as String: kSecClassGenericPassword as String,
                    kSecAttrAccount as String: key,
                    kSecValueData as String: data,
                    kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
                ] as CFDictionary
                
                status = SecItemAdd(newQuery, nil)
            }
        }
    }
    
    // Delete value from Keychain
    static func deleteValueFromKeychain(key: String) {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key
        ] as CFDictionary
        
        SecItemDelete(query)
    }
    
    // Check if both access and refresh tokens are present in Keychain
    static func areTokensPresent() -> Bool {
        if retrieveAccessToken() != nil && retrieveRefreshToken() != nil {
            return true
        } else {
            return false
        }
    }
}

class deviceIdentifier {
    static func retrieve() -> String {
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
           return uuid
        } else {
            ErrorHandler.showErrorMessage(title: "Device ID Error", message: "Unable to retrieve Device ID.")
            return ""
        }
    }
}

class NotificationManager: NSObject {
    static func registerForRemoteNotificationsIfAccepted() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                    if granted {
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    } else {
                        if let error = error {
                            ErrorHandler.showErrorMessage(for: error, title: "Notification Error", message: "Failed to gain notification authorization")
                        } else {
                            ErrorHandler.showErrorMessage(title: "Notification Error", message: "Failed to gain notification authorization")
                        }
                    }
                }
            case .provisional, .ephemeral, .notDetermined, .denied:
                break
            @unknown default:
                break
            }
        }
    }
}

//Decodable Structs

struct ServerVersion: Decodable {
    let version: String
}

struct Tokens: Decodable {
    let access_token: String
    let refresh_token: String
}

struct AccessToken: Decodable {
    let access_token: String
}

struct AuthTest: Decodable {
    let logged_in_as: String
}

struct ScoutUnit: Decodable, Identifiable {
    let id: Int
    let scoutbookID: Int
    let unitTypeID: Int
    let number: Int
    let gender: Int
    let scoutmasterID: Int?
    let name: String
    
    // Coding keys to map the JSON keys to the struct's property names
    enum CodingKeys: String, CodingKey {
        case id
        case scoutbookID = "scoutbook_id"
        case unitTypeID = "unit_type_id"
        case number
        case gender
        case scoutmasterID = "scoutmaster_id"
        case name
    }
}

struct MeritBadge: Decodable {
    let id: Int
    let scoutbookID: Int?
    let name: String
    let active: Int
    let eagleRequired: Int
    
    // Coding keys to map the JSON keys to the struct's property names
    enum CodingKeys: String, CodingKey {
        case id
        case scoutbookID = "scoutbook_id"
        case name
        case active
        case eagleRequired = "eagle_required"
    }
}

struct RankAdvancementEvent: Decodable {
    let id: Int
    let name: String
    let date: Date? // Change from Int? to Date?
    
    // Coding keys to map the JSON keys to the struct's property names
    enum CodingKeys: String, CodingKey {
        case id
        case name = "name"
        case date
    }
    
    // Custom initializer to decode the date as an epoch time and convert it to a Date object
    init(id: Int, name: String, date: Int?) {
        self.id = id
        self.name = name
        // Convert epoch time to Date, if date exists
        self.date = date != nil ? Date(timeIntervalSince1970: TimeInterval(date!)) : nil
    }
    
    // Custom decoding initializer to handle the conversion from JSON to struct
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let dateEpoch = try container.decodeIfPresent(Int.self, forKey: .date)
        
        // Call the custom initializer to convert the epoch time to a Date
        self.init(id: id, name: name, date: dateEpoch)
    }
}

struct EarnedMeritBadge: Decodable, Identifiable {
    let id: Int
    let badgeID: Int
    let date: Date  // Changed from Int to Date
    
    // Coding keys to map the JSON keys to the struct's property names
    enum CodingKeys: String, CodingKey {
        case id
        case badgeID = "badge_id"
        case date
    }
    
    // Custom initializer to decode the date as an epoch time and convert it to a Date object
    init(id: Int, badgeID: Int, date: Int) {
        self.id = id
        self.badgeID = badgeID
        self.date = Date(timeIntervalSince1970: TimeInterval(date))  // Convert epoch to Date
    }
    
    // Custom decoding initializer to handle the conversion from JSON to struct
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let badgeID = try container.decode(Int.self, forKey: .badgeID)
        let dateEpoch = try container.decode(Int.self, forKey: .date)
        
        // Convert epoch to Date
        self.init(id: id, badgeID: badgeID, date: dateEpoch)
    }
}

class ObjectCache: ObservableObject {
    let apiManager = APIManager()
    @Published var scouts: [Scout] = []
    @Published var units: [ScoutUnit] = []
    @Published var meritBadges: [MeritBadge] = []
    
    // Refreshers
    public func refreshScouts() {
        apiManager.getScoutList { result in
            DispatchQueue.main.async {
                guard let newScouts = result else { return }
                
                // Iterate over the new scouts to update the existing ones or add new ones
                for newScout in newScouts {
                    if let existingScoutIndex = self.scouts.firstIndex(where: { $0.id == newScout.id }) {
                        // If the scout already exists, update the existing object in place
                        let existingScout = self.scouts[existingScoutIndex]
                        existingScout.firstName = newScout.firstName
                        existingScout.lastName = newScout.lastName
                        existingScout.unitName = newScout.unitName
                        existingScout.email = newScout.email
                        existingScout.phone = newScout.phone
                        existingScout.birthday = newScout.birthday
                        existingScout.meritBadges = newScout.meritBadges
                        existingScout.rankAdvancementEvents = newScout.rankAdvancementEvents
                    } else {
                        // If not found, add new scout to the array
                        self.scouts.append(newScout)
                    }
                }
                
                //check if scout hidden: check if any existing scout not in newScouts
                self.scouts = self.scouts.filter { scout in
                    newScouts.contains { $0.id == scout.id }
                }

            }
        }
    }

    public func refreshUnits() {
        apiManager.getUnitList { result in
            DispatchQueue.main.async {
                self.units = result ?? []
            }
        }
    }

    public func refreshMeritBadges() {
        apiManager.getMBList { result in
            DispatchQueue.main.async {
                self.meritBadges = result ?? []
            }
        }
    }
}

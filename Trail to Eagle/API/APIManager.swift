//
//  APIManager.swift
//  Trail to Eagle
//
//  Created by Eric Wagner-Roberts
//

import Foundation
import Combine

class APIManager: ObservableObject {
    @Published var tokensDidChange = PassthroughSubject<Void, Never>()
    private let baseURL = "https://trail-to-eagle.juno.global"
    
    // Test Functions
    // Tests if authentication is working
    public func authTest(completion: @escaping (String) -> Void) {
        let loginURL = URL(string: "\(baseURL)/whoami")!
        let accessToken = KeychainManager.retrieveAccessToken()
        sendRequest(to: loginURL, method: "GET", body: nil, authorizationToken: accessToken) { result in
            switch result {
                case .success(let data):
                    do {
                        let testResponse = try JSONDecoder().decode(AuthTest.self, from: data)
                        completion(testResponse.logged_in_as)
                    } catch {
                        ErrorHandler.apiError(errorIn: APIError.decodeFailed, location: "authTest")
                        completion("")
                    }
                case .failure(let error):
                    ErrorHandler.apiError(errorIn: error, location: "authTest")
                    completion("")
            }
        }
    }
    
    //Primary Functions
    public func login(username: String, password: String, completion: @escaping (Bool) -> Void) {
        let loginURL = URL(string: "\(baseURL)/login")!
        let body: [String: Any] = [
            "username": username,
            "password": password,
            "device_identifier": deviceIdentifier.retrieve()
        ]
        sendRequest(to: loginURL, method: "POST", body: body) { result in
            switch result {
                case .success(let data):
                    do {
                        let tokens = try JSONDecoder().decode(Tokens.self, from: data)
                        KeychainManager.storeTokensInKeychain(accessToken: tokens.access_token, refreshToken: tokens.refresh_token)
                        DispatchQueue.main.async {
                            self.tokensDidChange.send()
                        }
                        NotificationManager.registerForRemoteNotificationsIfAccepted()
                    } catch {
                        ErrorHandler.apiError(errorIn: APIError.decodeFailed, location: "login")
                    }
                case .failure(let error):
                ErrorHandler.apiError(errorIn: error, location: "login")
            }
            completion(true)
        }
    }
    
    public func version(completion: @escaping (String) -> Void) {
        let versionURL = URL(string: "\(baseURL)/version")!
        sendRequest(to: versionURL, method: "GET", body: nil) { result in
            switch result {
                case .success(let data):
                    do {
                        let version = try JSONDecoder().decode(ServerVersion.self, from: data)
                        completion(version.version)
                    } catch {
                        ErrorHandler.apiError(errorIn: APIError.decodeFailed, location: "version")
                        completion("")
                    }
                case .failure(let error):
                    ErrorHandler.apiError(errorIn: error, location: "version")
                    completion("")
            }
        }
    }
    
    public func updateDeviceToken(deviceToken: String, completion: @escaping (Result<Bool, APIError>) -> Void) {
        let updateTokenURL = URL(string: "\(baseURL)/update-token")!
        let accessToken = KeychainManager.retrieveAccessToken()
        let body: [String: Any] = [
            "device_identifier": deviceIdentifier.retrieve(),
            "device_token": deviceToken
        ]
        sendRequest(to: updateTokenURL, method: "POST", body: body, authorizationToken: accessToken) { result in
            switch result {
                case .success:
                    completion(.success(true))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    // Scout Related Functions
    // Retrieve Scout Profile Image
    public func getScoutProfileImage(scoutbookID: Int, completion: @escaping (Data?) -> Void) {
        let scoutImageEndpointURL = URL(string: "\(baseURL)/scout-image?scoutbook_id=\(scoutbookID)")!
        let accessToken = KeychainManager.retrieveAccessToken()
        sendRequest(to: scoutImageEndpointURL, method: "GET", body: nil, authorizationToken: accessToken) { result in
            switch result {
                case .success(let data):
                    completion(data)
                case .failure(let error):
                    print("Failed to fetch image: \(error)")
                    completion(nil)
            }
        }
    }
    
    // Retrieve Merit Badge Image
    public func getMeritBadgeImage(scoutbookID: Int, completion: @escaping (Data?) -> Void) {
        let mbImageEndpointURL = URL(string: "\(baseURL)/mb-image?scoutbook_id=\(scoutbookID)")!
        let accessToken = KeychainManager.retrieveAccessToken()
        sendRequest(to: mbImageEndpointURL, method: "GET", body: nil, authorizationToken: accessToken) { result in
            switch result {
                case .success(let data):
                    completion(data)
                case .failure(let error):
                    print("Failed to fetch image: \(error)")
                    completion(nil)
            }
        }
    }
    
    // Retrieve Unit List
    public func getUnitList(completion: @escaping ([ScoutUnit]?) -> Void) {
        let unitListEndpointURL = URL(string: "\(baseURL)/units")!
        let accessToken = KeychainManager.retrieveAccessToken()
        sendRequest(to: unitListEndpointURL, method: "GET", body: nil, authorizationToken: accessToken) { result in
            switch result {
                case .success(let data):
                    do {
                        let units = try JSONDecoder().decode([ScoutUnit].self, from: data)
                        completion(units)
                    } catch {
                        print("Failed to decode units: \(error)")
                        completion(nil)
                    }
                case .failure(let error):
                    print("Did not obtain data: \(error)")
                    completion(nil)
            }
        }
    }
    
    // Retrieve Merit Badge List
    public func getMBList(completion: @escaping ([MeritBadge]?) -> Void) {
        let mbListEndpointURL = URL(string: "\(baseURL)/merit-badges")!
        let accessToken = KeychainManager.retrieveAccessToken()
        sendRequest(to: mbListEndpointURL, method: "GET", body: nil, authorizationToken: accessToken) { result in
            switch result {
                case .success(let data):
                    do {
                        let meritBadges = try JSONDecoder().decode([MeritBadge].self, from: data)
                        completion(meritBadges)
                    } catch {
                        print("Failed to decode merit badges: \(error)")
                        completion(nil)
                    }
                case .failure(let error):
                    print("Did not obtain data: \(error)")
                    completion(nil)
            }
        }
    }

    // Retrieve Scout Preview List
    public func getScoutList(completion: @escaping ([Scout]?) -> Void) {
        let scoutListEndpointURL = URL(string: "\(baseURL)/scout-list")!
        let accessToken = KeychainManager.retrieveAccessToken()
        sendRequest(to: scoutListEndpointURL, method: "GET", body: nil, authorizationToken: accessToken) { result in
            switch result {
                case .success(let data):
                    do {
                        let scouts = try JSONDecoder().decode([Scout].self, from: data)
                        completion(scouts)
                    } catch {
                        print("Failed to decode scouts: \(error)")
                        completion(nil)
                    }
                case .failure(let error):
                    print("Did not obtain data: \(error)")
                    completion(nil)
            }
        }
    }
    
    // Retrieve Scout
    public func getScout(scoutID: Int, completion: @escaping ([Scout]?) -> Void) {
        let scoutEndpointURL = URL(string: "\(baseURL)/scout?scout_id=\(scoutID)")!
        let accessToken = KeychainManager.retrieveAccessToken()
        sendRequest(to: scoutEndpointURL, method: "GET", body: nil, authorizationToken: accessToken) { result in
            switch result {
                case .success(let data):
                    do {
                        let scout = try JSONDecoder().decode([Scout].self, from: data)
                        completion(scout)
                    } catch {
                        print("Failed to decode scout: \(error)")
                        completion(nil)
                    }
                case .failure(let error):
                    print("Did not obtain data: \(error)")
                    completion(nil)
            }
        }
    }
    
    public func getHiddenScouts(completion: @escaping ([Scout]?) -> Void) {
        let hiddenScoutsURL = URL(string: "\(baseURL)/hidden-scout-list")!
        let accessToken = KeychainManager.retrieveAccessToken()
        
        sendRequest(to: hiddenScoutsURL, method: "GET", body: nil, authorizationToken: accessToken) { result in
            switch result {
            case .success(let data):
                print("Hidden scouts retrieved")
                do {
                    let scouts = try JSONDecoder().decode([Scout].self, from: data)
                    completion(scouts)
                } catch {
                    print("Failed to decode rseponse: \(error)")
                    completion(nil)
                }
            case .failure(let error):
                ErrorHandler.apiError(errorIn: error, location: "getHiddenScouts")
            }
        }
        
    }

    // Setter Functions
    // Update the Scout's birthday on the Backend
    public func setScoutBirthday(for scoutID: Int, to newBirthday: Date) {
        let scoutBirthdayURL = URL(string: "\(baseURL)/update-birthday")!
        let accessToken = KeychainManager.retrieveAccessToken()
        
        let epochSeconds = Int(newBirthday.timeIntervalSince1970)

        let body: [String: Int] = [
            "scout_id": scoutID,
            "birthday": epochSeconds
        ]

        sendRequest(to: scoutBirthdayURL, method: "POST", body: body, authorizationToken: accessToken) { result in
            switch result {
                case .success(_):
                    print("Set Birthday Successfully: \(epochSeconds)")
                case .failure(let error):
                    ErrorHandler.apiError(errorIn: error, location: "setScoutBirthday")
            }
        }
    }
    
    public func setHiddenStatus(for scoutID: Int, to newStatus: Bool) {
        let hiddenStatusUrl = URL(string: "\(baseURL)/update-hidden")!
        let accessToken = KeychainManager.retrieveAccessToken()
        
        print("SCOUT ID: \(scoutID)")
        
        let body: [String: Any] = [
            "scout_id": scoutID,
            "hidden": newStatus
        ]
        
        sendRequest(to: hiddenStatusUrl, method: "POST", body: body, authorizationToken: accessToken) { result in
            switch result {
            case .success(_):
                print("Set hidden status successfully: \(newStatus)")
            case .failure(let error):
                ErrorHandler.apiError(errorIn: error, location: "setHiddenStatus")
            }
        }
    }
    
    // Helper Functions
    // Handle API calls to endpoints
    /*private func sendRequest(to url: URL, method: String, body: [String: Any]?, authorizationToken: String? = nil, completion: @escaping (Result<Data, APIError>) -> Void) {
        var request = URLRequest(url: url)
        let refreshURL = URL(string: "\(baseURL)/refresh")!
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authorizationToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                completion(.failure(.serializationFailed))
                return
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.requestFailed))
                return
            }
            
            if httpResponse.statusCode == 200, let data = data {
                completion(.success(data))
            } else {
                if httpResponse.statusCode == 401 {
                    // Unauthorized
                    if (url == refreshURL) {
                        // Refresh Token needs to be refreshed. Mark unauthorize here and logout will occur in refreshAndRetry function.
                        completion(.failure(.unauthorized))
                    } else {
                        // Refresh Access Token
                        self?.refreshAndRetry(to: url, method: method, body: body, authorizationToken: authorizationToken, completion: completion)
                    }
                } else if httpResponse.statusCode == 400 {
                    completion(.failure(.badRequest))
                } else {
                    completion(.failure(.requestFailed))
                }
            }
        }
        task.resume()
    }*/
    
    private func sendRequest(to url: URL, method: String, body: [String: Any]?, authorizationToken: String? = nil, completion: @escaping (Result<Data, APIError>) -> Void) {
        var request = URLRequest(url: url)
        let refreshURL = URL(string: "\(baseURL)/refresh")!
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authorizationToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                print("‼️ JSON Serialization Failed: \(error.localizedDescription)")
                completion(.failure(.serializationFailed))
                return
            }
        }
        
        print("📡 Sending \(method) request to: \(url.absoluteString)")
        print("📝 Headers: \(request.allHTTPHeaderFields ?? [:])")
        if let body = body, let jsonData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted), let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📦 Request Body: \(jsonString)")
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("🚨 Network Request Error: \(error.localizedDescription)")
                completion(.failure(.requestFailed))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("🚨 No HTTP Response Received")
                completion(.failure(.requestFailed))
                return
            }
            
            print("📬 Response Status Code: \(httpResponse.statusCode)")
            
            if let responseData = data, let responseString = String(data: responseData, encoding: .utf8) {
                print("📥 Response Data: \(responseString)")
            } else {
                print("📭 Response Data is empty")
            }

            switch httpResponse.statusCode {
            case 200:
                if let data = data {
                    completion(.success(data))
                } else {
                    print("❌ Error: No data returned")
                    completion(.failure(.requestFailed))
                }
            case 400:
                print("❌ Bad Request (400)")
                completion(.failure(.badRequest))
            case 401:
                print("❌ Unauthorized (401)")
                if url == refreshURL {
                    print("⚠️ Refresh token expired, triggering logout.")
                    completion(.failure(.unauthorized))
                } else {
                    print("🔄 Attempting token refresh...")
                    self?.refreshAndRetry(to: url, method: method, body: body, authorizationToken: authorizationToken, completion: completion)
                }
            default:
                print("❌ Unexpected Error (Status Code: \(httpResponse.statusCode))")
                completion(.failure(.requestFailed))
            }
        }
        
        task.resume()
    }


    // Called when access token is expired. Refreshes it if the refresh token is valid otherwise logs out.
    private func refreshAndRetry(to url: URL, method: String, body: [String: Any]?, authorizationToken: String?, completion: @escaping (Result<Data, APIError>) -> Void) {
        refresh { [weak self] result in
            switch result {
                case .success:
                    // Retry the original request with the new token
                    self?.sendRequest(to: url, method: method, body: body, authorizationToken: KeychainManager.retrieveAccessToken(), completion: completion)
                case .failure(let refreshError):
                    // Unable to refresh token.
                    if (refreshError == APIError.unauthorized) {
                        // Error caused by expired refresh token. Remove tokens from keychain (logout)
                        self?.removeTokens()
                    }
                    // Pass Error up the chain.
                    completion(.failure(refreshError))
            }
        }
    }

    // Function to refresh the Access Token
    private func refresh(completion: @escaping (Result<Void, APIError>) -> Void) {
        let loginURL = URL(string: "\(baseURL)/refresh")!
        let refreshToken = KeychainManager.retrieveRefreshToken()
        sendRequest(to: loginURL, method: "POST", body: nil, authorizationToken: refreshToken) { result in
            switch result {
                case .success(let data):
                    do {
                        let newToken = try JSONDecoder().decode(AccessToken.self, from: data)
                        KeychainManager.updateAccessTokenInKeychain(newAccessToken: newToken.access_token)
                        if (newToken.access_token != KeychainManager.retrieveAccessToken()) {
                            completion(.failure((APIError.tokenSaveFailed)))
                        } else {
                            NotificationManager.registerForRemoteNotificationsIfAccepted()
                            completion(.success(())) // Refresh succeeded
                        }
                    } catch {
                        completion(.failure(APIError.decodeFailed)) // Decode failed
                    }
                case .failure(let error):
                    completion(.failure(error)) // Other failure (e.g., network error)
            }
        }
    }
    
    //Passthrough to allow for call to be published
    public func removeTokens() {
        KeychainManager.removeTokens()
        DispatchQueue.main.async {
            self.tokensDidChange.send()
        }
    }
}

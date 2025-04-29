//
//  Scout.swift
//  Trail to Eagle
//
//  Created by Eric Wagner-Roberts on 3/15/25.
//

import Foundation

class Scout: Decodable, Identifiable, ObservableObject {
    // Imported Values
    var id: Int
    @Published var scoutbookID: Int?
    @Published var firstName: String
    @Published var lastName: String
    @Published var unitName: String?
    @Published var email: String?
    @Published var phone: String?
    @Published var birthday: Date?
    @Published var meritBadges: [EarnedMeritBadge]?
    @Published var rankAdvancementEvents: [RankAdvancementEvent]?
    @Published var profilePicture: Data?

    // Coding keys to map JSON keys to class properties
    enum CodingKeys: String, CodingKey {
        case id
        case scoutbookID = "scoutbook_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case unitName = "unit_name"
        case email
        case phone
        case birthday
        case meritBadges = "merit_badges"
        case rankAdvancementEvents = "rank_advancement_events"
    }
    
    // Designated initializer
    init(id: Int, scoutbookID: Int?, firstName: String, lastName: String, unitName: String?, email: String?, phone: String?, birthdayEpoch: Int?, meritBadges: [EarnedMeritBadge]?, rankAdvancementEvents: [RankAdvancementEvent]?) {
        self.id = id
        self.scoutbookID = scoutbookID
        self.firstName = firstName
        self.lastName = lastName
        self.unitName = unitName
        self.email = email
        self.phone = phone
        self.meritBadges = meritBadges
        self.rankAdvancementEvents = rankAdvancementEvents
        // Convert epoch time to Date, if date exists
        self.birthday = birthdayEpoch != nil ? Date(timeIntervalSince1970: TimeInterval(birthdayEpoch ?? 0)) : nil
    }
    
    // Convenience initializer for decoding from JSON
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let scoutbookID = try container.decodeIfPresent(Int.self, forKey: .scoutbookID)
        let firstName = try container.decode(String.self, forKey: .firstName)
        let lastName = try container.decode(String.self, forKey: .lastName)
        let unitName = try container.decodeIfPresent(String.self, forKey: .unitName)
        let email = try container.decodeIfPresent(String.self, forKey: .email)
        let phone = try container.decodeIfPresent(String.self, forKey: .phone)
        let birthdayEpoch = try container.decodeIfPresent(Int.self, forKey: .birthday)
        let meritBadges = try container.decodeIfPresent([EarnedMeritBadge].self, forKey: .meritBadges)
        let rankAdvancementEvents = try container.decodeIfPresent([RankAdvancementEvent].self, forKey: .rankAdvancementEvents)
        
        // Call the designated initializer
        self.init(id: id, scoutbookID: scoutbookID, firstName: firstName, lastName: lastName, unitName: unitName, email: email, phone: phone, birthdayEpoch: birthdayEpoch, meritBadges: meritBadges, rankAdvancementEvents: rankAdvancementEvents)
    }
    
    // Computed Properties
    var currentRank: (name: String, date: Date, level: Int, daysAtRank: Int) {
        guard let latestDate = rankAdvancementEvents?.compactMap({ $0.date }).max(),
              let event = rankAdvancementEvents?.first(where: { $0.date == latestDate }) else {
            return ("No Rank", Date(timeIntervalSince1970: 0), 0, 0)
        }

        let rankName = event.name
        let rankLevel = getRankLevel(of: rankName)
        let earnedDate = latestDate
        let daysSinceEarned = Calendar.current.dateComponents([.day], from: earnedDate, to: Date()).day ?? 0
        
        return (rankName, earnedDate, rankLevel, daysSinceEarned)
    }
    
    var progress: Double {
        switch currentRank.level {
        case 0: return 0.0 // None/AOL
        case 1: return 0.05 // Scout (5%)
        case 2: return 0.2  // Tenderfoot (15%)
        case 3: return 0.35 // Second Class (15%)
        case 4: return 0.5  // First Class (15%)
        case 5: return 0.65 // Star (15%)
        case 6: return 0.8  // Life (15%)
        case 7: return 1.0  // Eagle (20%)
        default: return 0.0
        }
    }
    
    var riskValue: (value: Int, label: String, details: String) {
        let timeAtCurrentRank = self.currentRank.daysAtRank
        let lowerRanksLeft = max(0, 4 - self.currentRank.level) // Ranks below First Class

        // Determine minimum required days for advancement
        let minDaysRequired: Int = {
            switch self.currentRank.level {
            case 4:
                return max(0, Calendar.current.dateComponents([.day], from: Date(), to: Calendar.current.date(byAdding: .month, value: 16, to: Date())!).day! - timeAtCurrentRank)
            case 5:
                return max(0, Calendar.current.dateComponents([.day], from: Date(), to: Calendar.current.date(byAdding: .month, value: 12, to: Date())!).day! - timeAtCurrentRank)
            case 6:
                return max(0, Calendar.current.dateComponents([.day], from: Date(), to: Calendar.current.date(byAdding: .month, value: 6, to: Date())!).day! - timeAtCurrentRank)
            default:
                return Calendar.current.dateComponents([.day], from: Date(), to: Calendar.current.date(byAdding: .month, value: 16, to: Date())!).day!
            }
        }()
        
        // Calculate days until 18th birthday
        guard let birthday = self.birthday else { return (-1, "Unknown", "Unknown") }
        guard let eighteenthBirthday = Calendar.current.date(byAdding: .year, value: 18, to: birthday) else { return (-1, "Unknown", "Unknown") }
        guard let daysUntil18 = Calendar.current.dateComponents([.day], from: Date(), to: eighteenthBirthday).day else { return (-1, "Unknown", "Unknown") }
        
        // Buffer and risk calculations
        let bufferDays = daysUntil18 - minDaysRequired
        if bufferDays < 0 { return ( 100, "Not Possible", "Buffer Days: \(bufferDays)\nDays Until 18: \(daysUntil18)\nMinimum Required: \(minDaysRequired)") }

        let bufferRisk = (100 * Double(minDaysRequired)) / Double(daysUntil18)
        
        if lowerRanksLeft <= 0 { // If there are no lower ranks left.
            let timeLeftRisk = min(99.0, max(0.0, Double((100 * (365 - daysUntil18)) / 365)))
            let risk = min(99, Int((bufferRisk + timeLeftRisk).rounded()))
            return (risk, riskLabel(of: risk), "Risk: \(risk)\nBuffer Days: \(bufferDays)\nDays Until 18: \(daysUntil18)\nBuffer Risk: \(bufferRisk)\nTime Left Risk: \(timeLeftRisk)")
        } else {
            let rankRisk = 50 * Double(lowerRanksLeft) / Double(max(1, bufferDays))
            let risk = min(99, Int((bufferRisk + rankRisk).rounded()))
            return (risk, riskLabel(of: risk), "Risk: \(risk)\nBuffer Days: \(bufferDays)\nDays Until 18: \(daysUntil18)\nBuffer Risk: \(bufferRisk)\nRank Risk: \(rankRisk)")
        }
    }
    
    private func riskLabel(of risk: Int) -> String {
        switch risk {
        case 0: return "No Risk"
        case 1...30: return "Low Risk"
        case 30...60: return "Moderate Risk"
        case 60...80: return "High Risk"
        case 80...99: return "Extreme Risk"
        case 100: return "Not Possible"
        default: return "No Risk"
        }
    }

    // Convert rank name to a numerical level
    private func getRankLevel(of rankName: String) -> Int {
        switch rankName {
        case "Arrow of Light": return 0
        case "Scout": return 1
        case "Tenderfoot": return 2
        case "Second Class": return 3
        case "First Class": return 4
        case "Star": return 5
        case "Life": return 6
        case "Eagle": return 7
        default: return 0
        }
    }
}

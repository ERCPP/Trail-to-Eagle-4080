//
//  ScoutDetailView.swift
//  Trail to Eagle
//
//  Created by Eric Wagner-Roberts on 3/6/25.
//

import SwiftUI
import Charts
import Foundation

struct MeritBadgeProgress: Identifiable {
    let id = UUID()
    let date: Date
    let meritBadgesEarned: Int
    let cumulativeRankAdvancements: Int
}

extension Scout {
    var meritBadgeChartData: [MeritBadgeProgress] {
        guard let meritBadges = meritBadges, let rankEvents = rankAdvancementEvents, !rankEvents.isEmpty else { return [] }

        let calendar = Calendar.current
        let startDate = rankEvents.compactMap { $0.date }.min() ?? Date()
        let endDate = Date()
        let totalMonths = calendar.dateComponents([.month], from: startDate, to: endDate).month ?? 12
        
        let intervalValue = totalMonths > 18 ? 6 : 3  // Use 6 months for longer durations, otherwise 3 months
        
        var dataEntries: [MeritBadgeProgress] = []
        var cumulativeRankCount = 0

        var currentDate = calendar.startOfDay(for: startDate)
        while currentDate <= endDate {
            guard let nextDate = calendar.date(byAdding: .month, value: intervalValue, to: currentDate) else {
                print("Error: Could not calculate next date from \(currentDate)")
                break
            }

            let meritBadgeCount = meritBadges.filter { $0.date >= currentDate && $0.date < nextDate }.count
            let rankAdvancementCount = rankEvents.filter { ($0.date ?? Date()) >= currentDate && ($0.date ?? Date()) < nextDate }.count

            cumulativeRankCount += rankAdvancementCount

            dataEntries.append(MeritBadgeProgress(date: currentDate, meritBadgesEarned: meritBadgeCount, cumulativeRankAdvancements: cumulativeRankCount))

            currentDate = nextDate
            if currentDate >= endDate { break } // Prevent infinite loops
        }

        return dataEntries
    }
}

struct ScoutDetailView: View {
    @ObservedObject var objectCache: ObjectCache
    @ObservedObject var scout: Scout
    @State private var isEditing = false
    @State private var showDetails = false
    @State private var selectedBirthday: Date
    
    init(objectCache: ObjectCache, scout: Scout) {
        self.objectCache = objectCache
        self.scout = scout

        if let birthday = scout.birthday {
            
            let calendar = Calendar(identifier: .gregorian)
            let localTimeZone = TimeZone.current  // Ensure it’s in the user’s time zone

            // Extract just Year-Month-Day components
            var components = calendar.dateComponents(in: TimeZone(secondsFromGMT: 0)!, from: birthday)
            
            // Remove time component and reconstruct in local timezone
            components.hour = 0
            components.minute = 0
            components.second = 0
            components.timeZone = localTimeZone

            if let normalizedDate = calendar.date(from: components) {
                _selectedBirthday = State(initialValue: normalizedDate)
            } else {
                _selectedBirthday = State(initialValue: Date()) // Fallback to today
            }
        } else {
            _selectedBirthday = State(initialValue: Date())
        }
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            if scout.currentRank.name == "Eagle" {
                VStack {
                    HStack {
                        Spacer()
                        EagleScoutDetailViewBanner()
                            .rotationEffect(.degrees(-45))
                            .position(x: UIScreen.main.bounds.width - 45, y: 40)
                    }
                    Spacer()
                }
            }
            ScrollView {
                VStack {
                    HStack {
                        Spacer()
                        Button(isEditing ? "Save" : "Edit") {
                            if isEditing {
                                updateScoutBirthday()
                            }
                            isEditing.toggle()
                        }
                        .font(.headline)
                        .padding(.trailing)
                    }
                    ZStack {
                        if let imageData = scout.profilePicture, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 122, height: 122)
                                .clipShape(Circle())
                                .padding()
                        } else {
                            if scout.currentRank.level == 3 { // Second Class
                                Image("SecondClassInsignia")
                                    .resizable()
                                    .renderingMode(.template)
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(Color("AccentColor"))
                                    .frame(width: 85)
                                    .padding()
                                    .onAppear {
                                        if let scoutbookID = scout.scoutbookID {
                                            objectCache.apiManager.getScoutProfileImage(scoutbookID: scoutbookID) { data in
                                                if let data = data {
                                                    scout.profilePicture = data
                                                }
                                            }
                                        }
                                    }
                            } else if scout.currentRank.level == 0 { // No Rank
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .renderingMode(.template)
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(Color("AccentColor"))
                                    .frame(width: 122, height: 122)
                                    .padding()
                                    .onAppear {
                                        if let scoutbookID = scout.scoutbookID {
                                            objectCache.apiManager.getScoutProfileImage(scoutbookID: scoutbookID) { data in
                                                if let data = data {
                                                    scout.profilePicture = data
                                                }
                                            }
                                        }
                                    }
                            } else {
                                Image("\(scout.currentRank.name.replacingOccurrences(of: " ", with: "").trimmingCharacters(in: .whitespacesAndNewlines))Insignia")
                                    .resizable()
                                    .renderingMode(.template)
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(Color("AccentColor"))
                                    .frame(width: 100)
                                    .padding()
                                    .onAppear {
                                        if let scoutbookID = scout.scoutbookID {
                                            objectCache.apiManager.getScoutProfileImage(scoutbookID: scoutbookID) { data in
                                                if let data = data {
                                                    scout.profilePicture = data
                                                }
                                            }
                                        }
                                    }
                            }
                        }
                        if scout.currentRank.name != "Eagle" {
                            // Progress bar surrounding the profile image
                            Circle()
                                .stroke(lineWidth: 8)
                                .foregroundColor(Color("AccentColor").opacity(0.2))
                                .frame(width: 130, height: 130)
                            
                            // Thicker progress bar around the profile picture
                            Circle()
                                .trim(from: 0, to: CGFloat(scout.progress))
                                .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                .foregroundColor(Color("AccentColor"))
                                .rotationEffect(.degrees(-90)) // To start the progress from the top
                                .frame(width: 130, height: 130)
                        }
                    }
                    
                    Text("\(scout.firstName) \(scout.lastName)")
                        .font(.largeTitle)
                        .bold()
                    Text("\(scout.unitName ?? "No Unit") - \(scout.currentRank.name)")
                        .font(.title3)
                        .foregroundColor(.gray)
                    
                    if scout.currentRank.name == "Eagle" {
                        Text("Earned Eagle: \(formattedDate(for: scout.currentRank.date))")
                            .font(.title2)
                            .foregroundColor(.blue)
                    } else {
                        if showDetails {
                            Text("\(scout.riskValue.details)")
                                .foregroundColor(Color("AccentColor"))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color("ListBackgroundColor"))
                                .cornerRadius(10)
                                .padding(.horizontal)
                                .onTapGesture {
                                    showDetails.toggle()
                                }
                                .animation(.easeInOut, value: showDetails)
                        } else {
                            Text("\(scout.riskValue.label)")
                                .font(.title2)
                                .foregroundColor(Color("ScoutingAmericaRedColor"))
                                .onTapGesture { showDetails.toggle() }
                                .animation(.easeInOut, value: showDetails)
                        }
                    }
                    
                    if isEditing {
                        DatePicker("Birthday", selection: $selectedBirthday, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .padding()
                    } else {
                        Chart {
                            ForEach(scout.meritBadgeChartData) { data in
                                BarMark(
                                    x: .value("Date", data.date),
                                    y: .value("Merit Badges", data.meritBadgesEarned)
                                )
                                .foregroundStyle(.blue)
                                LineMark(
                                    x: .value("Date", data.date),
                                    y: .value("Cumulative Rank Advancements", data.cumulativeRankAdvancements)
                                )
                                .foregroundStyle(Color("ScoutingAmericaRedColor"))
                                .lineStyle(StrokeStyle(lineWidth: 2))
                                .interpolationMethod(.stepStart)
                            }
                        }
                        .frame(height: 300)
                        .padding()
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .month, count: scout.meritBadgeChartData.count > 6 ? 6 : 3)) { _ in
                                AxisGridLine()
                                AxisValueLabel(format: .dateTime.year().month(.abbreviated))
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        Spacer()
                    }
                }
            }
            .environment(\EnvironmentValues.refresh as! WritableKeyPath<EnvironmentValues, RefreshAction?>, nil)
            .padding()
        }
    }
    
    private func updateScoutBirthday() {
        if selectedBirthday != scout.birthday {
            let calendar = Calendar(identifier: .gregorian)
            let utcTimeZone = TimeZone(secondsFromGMT: 0)!
            
            // Convert the selected date to midnight UTC
            var components = calendar.dateComponents(in: TimeZone.current, from: selectedBirthday)
            components.timeZone = utcTimeZone
            components.hour = 0
            components.minute = 0
            components.second = 0
            
            if let utcMidnightDate = calendar.date(from: components) {
                objectCache.apiManager.setScoutBirthday(for: scout.id, to: utcMidnightDate)
                scout.birthday = utcMidnightDate
            } else {
                print("Error converting selected birthday to UTC midnight")
            }
        }
    }

    private func formattedDate(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct EagleScoutDetailViewBanner: View {
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(Color("ScoutingAmericaRedColor"))
                .frame(width: 50, height: 400)
            Rectangle()
                .fill(Color.white)
                .frame(width: 50, height: 400)
            Rectangle()
                .fill(Color("ScoutingAmericaBlueColor"))
                .frame(width: 50, height: 400)
        }
    }
}

//
//  EagleScoutsView.swift
//  Trail to Eagle
//
//  Created by Eric Wagner-Roberts on 3/6/25.
//

import SwiftUI

struct EagleScoutsView: View {
    @ObservedObject var objectCache: ObjectCache
    @State private var selectedScout: Scout?
    @State private var hasLoaded = false
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            List(objectCache.scouts
                .filter { scout in
                    scout.currentRank.name == "Eagle"
                }
                .sorted { $0.currentRank.date > $1.currentRank.date }
            ) { scout in
                Button(action: {
                    selectedScout = scout
                }) {
                    EagleScoutListItem(apiManager: objectCache.apiManager, scout: scout)
                }
                .listRowBackground(Color("ListBackgroundColor"))
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Eagle Scouts")
            .refreshable { objectCache.refreshScouts() }
            .sheet(item: $selectedScout) { scout in
                ScoutDetailView(objectCache: objectCache, scout: scout)
            }
        }
        .onAppear {
            if !hasLoaded {
                objectCache.refreshScouts()
                hasLoaded = true
            }
        }
    }
}

// List Item for Eagle Scouts Page
struct EagleScoutListItem: View {
    @ObservedObject var apiManager: APIManager
    @ObservedObject var scout: Scout

    var body: some View {
        HStack {
            // Check if profileImageData is available
            if let imageData = scout.profilePicture, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            } else {
                // Fallback to default image if no profile image
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .onAppear {
                        // Fetch profile image if not already available
                        if let scoutbookID = scout.scoutbookID {
                            apiManager.getScoutProfileImage(scoutbookID: scoutbookID) { data in
                                if let dataTemp = data {
                                    DispatchQueue.main.async {
                                        scout.profilePicture = dataTemp
                                    }
                                }
                            }
                        }
                    }
            }
            VStack(alignment: .leading) {
                Text("\(scout.firstName) \(scout.lastName)")
                    .font(.headline)
                Text(scout.unitName ?? "No Unit")
                    .font(.subheadline)
                    .foregroundColor(Color("SecondaryAccentColor"))
                Text("Earned Eagle: \(formattedDate(for: scout.currentRank.date, timeZone: TimeZone(abbreviation: "UTC")!))")
                                .font(.subheadline)
                                .foregroundColor(Color("AccentColor"))
            }
            Spacer()
        }
        .padding(5)
    }
    
    func formattedDate(for date: Date, timeZone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

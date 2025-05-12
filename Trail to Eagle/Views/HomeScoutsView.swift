//
//  MainScoutsView.swift
//  Trail to Eagle
//
//  Created by Eric Wagner-Roberts on 3/6/25.
//

import SwiftUI

struct HomeScoutsView: View {
    @ObservedObject var objectCache: ObjectCache
    @State private var selectedScout: Scout?
    @State private var hasLoaded = false

    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            List(objectCache.scouts
                .filter { scout in
                    scout.currentRank.name != "Eagle"
                }
                .sorted { $0.riskValue > $1.riskValue}
            ) { scout in
                Button(action: {
                    selectedScout = scout
                }) {
                    ScoutListItem(apiManager: objectCache.apiManager, scout: scout)
                }
                .listRowBackground(Color("ListBackgroundColor"))
            }
            .scrollContentBackground(.hidden)
            .sheet(item: $selectedScout) { scout in
                ScoutDetailView(objectCache: objectCache, scout: scout)
                    .onDisappear() {
                        objectCache.refreshScouts()
                    }
            }
            .refreshable { objectCache.refreshScouts() }
        }
        .onAppear {
            if !hasLoaded {
                objectCache.refreshScouts()
                hasLoaded = true
            }
        }
    }
}

// List Item for Main Scouts Page
struct ScoutListItem: View {
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
                    .padding(.trailing)
            } else {
                // Fallback to default image if no profile image
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .padding(.trailing)
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
            Spacer()
            VStack(alignment: .leading) {
                HStack() {
                    VStack(alignment: .leading) {
                        Text("\(scout.firstName) \(scout.lastName)")
                            .font(.headline)
                            .foregroundColor(Color("AccentColor"))
                        Text(scout.unitName ?? "No Unit")
                            .font(.subheadline)
                            .foregroundColor(Color("SecondaryAccentColor"))
                        Text(scout.currentRank.name)
                            .font(.subheadline)
                            .foregroundColor(Color("SecondaryAccentColor"))
                        Text("\(scout.riskValue.label)")
                            .font(.subheadline)
                            .foregroundColor(Color("ScoutingAmericaRedColor"))
                    }
                    Spacer()
                    Image("\(scout.currentRank.name.replacingOccurrences(of: " ", with: "").trimmingCharacters(in: .whitespacesAndNewlines))Insignia")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color("AccentColor"))
                        .frame(width: 60)
                }
                ProgressView(value: scout.progress)
                    .tint(Color("ProgressBarColor"))
            }
        }
        .padding(5)
    }
}

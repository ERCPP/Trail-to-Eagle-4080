//
//  HiddenScoutsView.swift
//  Trail to Eagle
//
//  Created by milosz CS4080 on 5/11/25.
//

import SwiftUI

struct HiddenScoutsView: View {
    @ObservedObject var apiManager: APIManager
    @State private var scouts: [Scout] = []
    
    var body: some View {
        
        //display
        NavigationStack {
            VStack {
                List(self.scouts) { scout in
                    HiddenScoutListItem(apiManager: apiManager, scout: scout, scouts: $scouts)
                }
            }
            .navigationTitle("Hidden Scouts")
        }
        .onAppear {
            apiManager.getHiddenScouts { result in
                if (result != nil) {
                    self.scouts = result!
                }
            }
        }
    }
    
    
    struct HiddenScoutListItem: View {
        @ObservedObject var apiManager: APIManager
        @ObservedObject var scout: Scout
        @Binding var scouts: [Scout]
        
        var body: some View {
            HStack(alignment: .center) {
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
                VStack(alignment: .leading) {
                    Text("\(scout.firstName) \(scout.lastName)")
                        .font(.headline)
                        .foregroundColor(Color("AccentColor"))
                    Text(scout.unitName ?? "No Unit")
                        .font(.subheadline)
                        .foregroundColor(Color("SecondaryAccentColor"))
                }
                
                Spacer()
                
                Button(action:{
                    apiManager.setHiddenStatus(for: scout.id, to: false)
                    scouts.removeAll(where: { $0.id == scout.id } ) //remove from parent's list so it's not displayed
                }) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40) // Set explicit size for consistent shape
                        .background(Color("AccentColor"))
                        .cornerRadius(8)
                    
                }
            }
            .padding(5)
        }
    }
}

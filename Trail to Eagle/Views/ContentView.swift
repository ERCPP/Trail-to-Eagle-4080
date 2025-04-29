//
//  ContentView.swift
//  Trail to Eagle
//
//  Created by Eric Wagner-Roberts on 3/6/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    @State var objectCache: ObjectCache = ObjectCache()

    init() {
        let standardTabBarAppearance = UITabBarAppearance()
        let scrollTabBarAppearance = UITabBarAppearance()
        let scoutingAmericaGreyUIColor = UIColor(red: 81/255.0, green: 83/255.0, blue: 84/255.0, alpha: 1.0)
        scrollTabBarAppearance.configureWithTransparentBackground()
        standardTabBarAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        standardTabBarAppearance.backgroundColor = UIColor.clear
        scrollTabBarAppearance.stackedLayoutAppearance.normal.iconColor = scoutingAmericaGreyUIColor
        scrollTabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: scoutingAmericaGreyUIColor]
        
        UITabBar.appearance().standardAppearance = standardTabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = scrollTabBarAppearance

        // Customize Navigation Bar appearance
        let standardNavBarAppearance = UINavigationBarAppearance()
        let scrollNavBarAppearance = UINavigationBarAppearance()
        scrollNavBarAppearance.configureWithTransparentBackground()
        standardNavBarAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        standardNavBarAppearance.backgroundColor = UIColor.clear

        UINavigationBar.appearance().standardAppearance = standardNavBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = scrollNavBarAppearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeScoutsView(objectCache: objectCache)
                    .navigationTitle("Scouts")
                    .navigationBarTitleDisplayMode(.large)
                    .navigationBarItems(trailing: NavigationLink(destination: SettingsView(objectCache: objectCache)) {
                        Image(systemName: "gear")
                            .font(.system(size: 20))
                    })
            }
            .tag(0)
            .tabItem {
                Label("On the Trail", systemImage: "figure.hiking")
            }

            NavigationStack {
                EagleScoutsView(objectCache: objectCache)
                    .navigationTitle("Eagle Scouts")
                    .navigationBarTitleDisplayMode(.large)
                    .navigationBarItems(trailing: NavigationLink(destination: SettingsView(objectCache: objectCache)) {
                    Image(systemName: "gear")
                        .font(.system(size: 20))
                })
            }
            .tag(1)
            .tabItem {
                Label("Eagled", systemImage: "flag.pattern.checkered.2.crossed")
            }
        }
        .background(Color("BackgroundColor").ignoresSafeArea()) // Ensures full background
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

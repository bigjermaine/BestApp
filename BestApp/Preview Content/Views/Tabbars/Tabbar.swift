//
//  Tabbar.swift
//  BestApp
//
//  Created by Daniel Jermaine on 18/06/2025.
//

import SwiftUI

struct Tabbar: View {
    @State private var selectedTab: Tab = .cards
    @StateObject private var badgeManager = BadgeManager()
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .cards:
                    HomeView()
                case .bonfire:
                    Text("bonfire")
                case .matches:
                    Text("matches")
                case .profile:
                    Text("profile")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.ignoresSafeArea())
            
            CustomTabBarView(selectedTab: $selectedTab, badgeCounts: badgeManager.badgeCounts)
        }
        .environmentObject(badgeManager)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    Tabbar()
}

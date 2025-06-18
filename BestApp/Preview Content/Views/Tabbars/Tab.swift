//
//  Tab.swift
//  BestApp
//
//  Created by Daniel Jermaine on 18/06/2025.
//


import SwiftUI

enum Tab {
    case cards, bonfire, matches, profile
}

struct CustomTabBarView: View {
    @Binding var selectedTab: Tab
    var badgeCounts: [Tab: Int] = [.cards: 10, .bonfire: 10]

    var body: some View {
        HStack {
            tabItem(iconName: "rectangle.stack", title: "Cards", tab: .cards)
            tabItem(iconName: "flame", title: "Bonfire", tab: .bonfire)
            tabItem(iconName: "message", title: "Matches", tab: .matches)
            profileTabItem()
        }
        .padding(.vertical, 12)
        .background(Color.black.ignoresSafeArea(edges: .bottom))
    }

    @ViewBuilder
    private func tabItem(iconName: String, title: String, tab: Tab) -> some View {
        VStack(spacing: 4) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(selectedTab == tab ? .white : .gray)

                if let count = badgeCounts[tab], count > 0 {
                    Text("\(count)")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.purple)
                        .clipShape(Circle())
                        .offset(x: 10, y: -10)
                }
            }
            Text(title)
                .font(.caption)
                .foregroundColor(selectedTab == tab ? .white : .gray)
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            selectedTab = tab
        }
    }

    @ViewBuilder
    private func profileTabItem() -> some View {
        VStack(spacing: 4) {
            Image("profilePic") 
                .resizable()
                .scaledToFill()
                .frame(width: 24, height: 24)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: selectedTab == .profile ? 2 : 0))
            Text("Profile")
                .font(.caption)
                .foregroundColor(selectedTab == .profile ? .white : .gray)
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            selectedTab = .profile
        }
    }
}

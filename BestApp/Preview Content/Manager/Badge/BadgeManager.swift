//
//  BadgeManager.swift
//  BestApp
//
//  Created by Daniel Jermaine on 18/06/2025.
//

import UIKit
import SwiftUI

class BadgeManager: ObservableObject {
    @Published var badgeCounts: [Tab: Int] = [
        .cards: 10,
        .bonfire: 10,
        .matches: 0,
        .profile: 0
    ]

    func updateBadge(for tab: Tab, count: Int) {
        badgeCounts[tab] = count
    }

    func incrementBadge(for tab: Tab) {
        badgeCounts[tab, default: 0] += 1
    }

    func clearBadge(for tab: Tab) {
        badgeCounts[tab] = 0
    }
}

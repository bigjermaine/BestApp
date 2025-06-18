//
//  NavigationState.swift
//  BestApp
//
//  Created by Daniel Jermaine on 18/06/2025.
//

import Foundation
import SwiftUI

class NavigationState: ObservableObject {
    
    @Published var path = NavigationPath()

    func push(to router: Route) {
        path.append(router)
    }
    
    func reset() {
        path.removeLast(path.count)
    }
    
    func pop() {
        path.removeLast()
    }
}


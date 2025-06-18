//
//  AgeRange.swift
//  BestApp
//
//  Created by Daniel Jermaine on 18/06/2025.
//


enum AgeRange: String, CaseIterable {
    case range18to25 = "18-25"
    case range25to50 = "25-50"
    case range50to60 = "50-60"

    var range: ClosedRange<Int> {
        switch self {
        case .range18to25:
            return 18...25
        case .range25to50:
            return 26...50
        case .range50to60:
            return 51...60
        }
    }
}

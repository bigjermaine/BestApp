//
//  OnboardingViewModel.swift
//  BestApp
//
//  Created by Daniel Jermaine on 18/06/2025.
//

import Foundation

class OnboardingViewModel: ObservableObject {
    @Published var gender: String = ""
    @Published var age: Int = 18
    @Published var name: String = ""
    @Published var interestedInGender: String = ""
    @Published var interestedInAgeRange: ClosedRange<Int> = 18...30

    func saveUser() {
        UserDefaults.standard.set(gender, forKey: "user_gender")
        UserDefaults.standard.set(age, forKey: "user_age")
        UserDefaults.standard.set(name, forKey: "user_name")
        UserDefaults.standard.set(interestedInGender, forKey: "user_interested_gender")
        UserDefaults.standard.set([interestedInAgeRange.lowerBound, interestedInAgeRange.upperBound], forKey: "user_interested_age")
    }
}

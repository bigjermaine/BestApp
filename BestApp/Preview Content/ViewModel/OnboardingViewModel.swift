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
    @Published var interestedInAgeRange: AgeRange = .range18to25
    @Published var allUsers: [UserModel] = DummyUserDatabase.users
    @Published var filteredUsers: [UserModel] = []

    init() {
        filterUsers(gender: gender, ageRange: interestedInAgeRange)
    }
    
    func filterUsers(gender: String, ageRange: AgeRange) {
        if gender == "Others" {
            filteredUsers = allUsers.filter { ["Male", "Female"].contains($0.gender) || ageRange.range.contains($0.age) }
        } else {
            filteredUsers = allUsers.filter { $0.gender == gender && ageRange.range.contains($0.age) }
            
        }
    }

    func saveUser() {
        UserDefaults.standard.set(gender, forKey: "user_gender")
        UserDefaults.standard.set(age, forKey: "user_age")
        UserDefaults.standard.set(name, forKey: "user_name")
        UserDefaults.standard.set(interestedInGender, forKey: "user_interested_gender")
        filterUsers(gender: interestedInGender, ageRange: interestedInAgeRange)
       
    }
}
